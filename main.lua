bump = require "lib.bump.bump"

-- setup a player object t hold an image
player = {
  x = 16,
  y = 16,
  xVelocity = 0,
  yVelocity = 0,
  acc = 100,
  maxSpeed = 600,
  friction = 20,
  gravity = 80,
  isJumping = false,
  isGrounded = false,
  hasReachedMax = false,
  jumpAcc = 500,
  jumpMaxSpeed = 9.5,
  img = nil
}

player.filter = function(item, other)
  local x, y, w, h = world:getRect(other)
  local px, py, pw, ph = world:getRect(item)
  local playerBottom = py + ph
  local otherBottom = y + h

  if playerBottom <= y then
    return 'slide'
  end
end

world = nil

ground_0 = {}
ground_1 = {}

function love.load(arg)
  world = bump.newWorld(16)

  player.img = love.graphics.newImage("assets/player_32.png")

  world:add(player, player.x, player.y, player.img:getWidth(), player.img:getHeight())

  world:add(ground_0, 120, 380, 640, 16)
  world:add(ground_1, 0, 448, 640, 32)
end

function love.update(dt)
  local goalX = player.x + player.xVelocity
  local goalY = player.y + player.yVelocity
  player.x, player.y, collisions, len = world:move(player, goalX, goalY, player.filter)

  for i, collision in ipairs(collisions) do
    if collision.touch.y > goalY then
      player.hasReachedMax = true
      player.isGrounded = false
    elseif collision.normal.y < 0 then
      player.hasReachedMax = false
      player.isGrounded = true
    end
  end

  -- Apply Friction
  player.xVelocity = player.xVelocity * (1 - math.min(dt * player.friction, 1))
  player.yVelocity = player.yVelocity * (1 - math.min(dt * player.friction, 1))

  -- Apply gravity
  player.yVelocity = player.yVelocity + player.gravity * dt

  if love.keyboard.isDown("left", "a") and player.xVelocity > -player.maxSpeed then
    player.xVelocity = player.xVelocity - player.acc * dt
  elseif love.keyboard.isDown("right", "d") and player.xVelocity < player.maxSpeed then
    player.xVelocity = player.xVelocity + player.acc * dt
  end

  -- The Jump code gets a lttle bit crazy.  Bare with me.
  if love.keyboard.isDown("up", "w") then
    if -player.yVelocity < player.jumpMaxSpeed and not player.hasReachedMax then
      player.yVelocity = player.yVelocity - player.jumpAcc * dt
    elseif math.abs(player.yVelocity) > player.jumpMaxSpeed then
      player.hasReachedMax = true
    end

    player.isGrounded = false -- we are no longer in contact with the ground
  end
end

function love.draw()
  love.graphics.draw(player.img, player.x, player.y)
  love.graphics.rectangle('fill', world:getRect(ground_0))
  love.graphics.rectangle('fill', world:getRect(ground_1))

  love.graphics.print(string.format("FPS: %s", love.timer.getFPS()), 10, 10)
end

function love.keypressed(key)
  if key ==  "escape" then
    love.event.push("quit")
  end
end
