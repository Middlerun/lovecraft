-- takes table of L values and returns N*(L-3) interpolated values
function interpolate1D(values, N)
  newData = {}
  for i = 1, #values - 3 do
    P = (values[i+3] - values[i+2]) - (values[i] - values[i+1])
    Q = (values[i] - values[i+1]) - P
    R = (values[i+2] - values[i])
    S = values[i+1]
    for j = 0, N-1 do
      x = j/N
      table.insert(newData, P*x^3 + Q*x^2 + R*x + S)
    end
  end
  return newData
end

function perlinComponent1D(seed, length, N, amplitude)
  rawData = {}
  finalData = {}
  for i = 1, math.ceil(length/N) + 3 do
    rawData[i] = amplitude * rand(seed, i)
  end
  interpData = interpolate1D(rawData, N)
  assert(#interpData >= length)
  for i = 1, length do
    finalData[i] = interpData[i]
  end
  return finalData
end

function perlin1D(seed, length, persistence, N, amplitude)
  data = {}
  for i = 1, length do
    data[i] = 0
  end
  for i = N, 1, -1 do
    compInterp = 2^(i-1)
    compAmplitude = amplitude * persistence^(N-i)
    comp = perlinComponent1D(seed+i, length, i, compAmplitude)
    for i = 1, length do
      data[i] = data[i] + comp[i]
    end
  end
  return data
end

function interpolate2D(values, N)
  newData1 = {}
  for r = 1, #values do
    newData1[r] = {}
    for c = 1, #values[r] - 3 do
      P = (values[r][c+3] - values[r][c+2]) - (values[r][c] - values[r][c+1])
      Q = (values[r][c] - values[r][c+1]) - P
      R = (values[r][c+2] - values[r][c])
      S = values[r][c+1]
      for j = 0, N-1 do
        x = j/N
        table.insert(newData1[r], P*x^3 + Q*x^2 + R*x + S)
      end
    end
  end
  
  newData2 = {}
  for r = 1, (#newData1-3) * N do
    newData2[r] = {}
  end
  for c = 1, #newData1[1] do
    for r = 1, #newData1 - 3 do
      P = (newData1[r+3][c] - newData1[r+2][c]) - (newData1[r][c] - newData1[r+1][c])
      Q = (newData1[r][c] - newData1[r+1][c]) - P
      R = (newData1[r+2][c] - newData1[r][c])
      S = newData1[r+1][c]
      for j = 0, N-1 do
        x = j/N
        newData2[(r-1)*N+j+1][c] = P*x^3 + Q*x^2 + R*x + S
      end
    end
  end
  
  return newData2
end

function perlinComponent2D(seed, width, height, N, amplitude)
  rawData = {}
  finalData = {}
  for r = 1, math.ceil(height/N) + 3 do
    rawData[r] = {}
    for c = 1, math.ceil(width/N) + 3 do
      rawData[r][c] = amplitude * rand(seed+r, c)
    end
  end
  interpData = interpolate2D(rawData, N)
  assert(#interpData >= height and #interpData[1] >= width)
  for r = 1, height do
    finalData[r] = {}
    for c = 1, width do
      finalData[r][c] = interpData[r][c]
    end
  end
  return finalData
end

function perlin2D(seed, width, height, persistence, N, amplitude)
  data = {}
  for r = 1, height do
    data[r] = {}
    for c = 1, width do
      data[r][c] = 0
    end
  end
  for i = N, 1, -1 do
    compInterp = 2^(i-1)
    compAmplitude = amplitude * persistence^(N-i)
    comp = perlinComponent2D(seed+i*1000, width, height, i, compAmplitude)
    for r = 1, height do
      for c = 1, width do
        data[r][c] = data[r][c] + comp[r][c]
      end
    end
  end
  return data
end

