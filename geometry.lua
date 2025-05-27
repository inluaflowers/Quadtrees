local Geometry = {}

function Geometry.is_point_in_rect(pX, pY, rX, rY, rW, rH) 
  return 
    pX >= rX and 
    pX <= rX + rW and
    pY >= rY and 
    pY <= rY + rH
end

function Geometry.is_rect_in_rect(r1x, r1y, r1w, r1h, r2x, r2y, r2w, r2h)
  return not (
    r1x + r1w < r2x or      -- r1 is left of r2
    r1x > r2x + r2w or      -- r1 is right of r2
    r1y + r1h < r2y or      -- r1 is above r2
    r1y > r2y + r2h         -- r1 is below r2
  )
end

function Geometry.is_point_in_circ(pX, pY, cX, cY, cR)
  local dx = (pX - cX)^2
  local dy = (pY - cY)^2
  local distance = dx + dy
  return distance <=  cR^2
end

function Geometry.is_circ_in_circ(cX1, cY1, cR1, cX2, cY2, cR2)
  local dx = (cX1 - cX2)^2
  local dy = (cY1 - cY2)^2
  local distance = dx + dy
  return distance <= (cR1 + cR2)^2
end

function Geometry.is_circ_in_rect(cX, cY, cR, rX, rY, rW, rH)



  local closestX = math.max(rX, math.min(cX, rX + rW))
  local closestY = math.max(rY, math.min(cY, rY + rH))
  local dx = (cX - closestX)^2
  local dy = (cY - closestY)^2
  local distance = dx + dy
  return distance <= cR^2
end


return Geometry