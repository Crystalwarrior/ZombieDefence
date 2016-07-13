function love.conf(t)
  t.identity = "ZombDef"
  t.version = "0.10.1"
  t.console = love.filesystem and not love.filesystem.isFused()

  t.window.title = "ZombDef"
  t.window.width = 640
  t.window.height = 480
  t.window.msaa = 4

  -- Less commonly used modules
  t.modules.joystick = false
  t.modules.physics = false
  t.modules.touch = false
  t.modules.video = false
end
