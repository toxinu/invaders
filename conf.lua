function love.conf(t)
  t.identity = "Invaders"
  t.version = "0.9.1"
  t.console = false

  t.window.title = "Invaders by socketubs"
  t.window.icon = "assets/images/icon_inverse.png"
  t.window.width = 600
  t.window.height = 600
  t.window.borderless = false
  t.window.resizable = false
  t.window.fullscreen = false
  t.window.vsync = true
  t.window.fsaa = 4
  t.window.display = 1
  t.window.highdpi = false
  t.window.srgb = false

  t.modules.audio = true
  t.modules.event = true
  t.modules.graphics = true
  t.modules.image = true
  t.modules.joystick = false
  t.modules.keyboard = true
  t.modules.math = true
  t.modules.mouse = true
  t.modules.physics = true
  t.modules.sound = true
  t.modules.system = true
  t.modules.timer = true
  t.modules.window = true
  t.modules.thread = false
end
