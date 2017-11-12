-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf('no')

local Lander = {}
Lander.vx = 0
Lander.vy = 0
Lander.x = 0
Lander.y = 0
Lander.angle = 270
Lander.engineOn = false
Lander.speed = 3
Lander.img = love.graphics.newImage("ship.png")
Lander.imgEngine = love.graphics.newImage("engine.png")
Lander.largeurImg = Lander.img:getWidth()
Lander.hauteurImg = Lander.img:getHeight()

local Plateform = {}
Plateform.hauteur = 15
Plateform.largeur = 50
Plateform.x = 0
Plateform.y = 0

local font = love.graphics.newFont(30)

local perdu = false
local gagne = false
local start = false
local fini = false

local sRestart = "Appuyer sur espace pour recommencer"
local sStart = "Appuyer sur espace pour commencer"

local valeurCarburant = 350
local carburant = valeurCarburant

local collision = false

local background = love.graphics.newImage("background.png")

local sonExplosion = love.audio.newSource("explosion.wav","static")
local sonEngine = love.audio.newSource("engineSound.wav","static")
local sonSucces = love.audio.newSource("succes.wav","static")


function love.load()
  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  
  Lander.x = largeur/2
  Lander.y = hauteur/2

  Plateform.x = math.random(largeur - Plateform.largeur)
  Plateform.y = hauteur  - Plateform.hauteur
  
  love.graphics.setFont(font)
  
  function resetGame()
    Lander.vx = 0
    Lander.vy = 0
    Lander.x = largeur/2
    Lander.y = hauteur/2
    Lander.angle = 270
    collision = false
    carburant = valeurCarburant
    perdu = false
    gagne = false
    Plateform.x = math.random(largeur - Plateform.largeur)
  end
  
end

function love.update(dt)
  --Debut du jeu
  if(love.keyboard.isDown("space")) then
      start = true
      if(fini == true) then
        resetGame()
      end
      fini = false
  end
  ----------------------------------
  if(start == true) and (fini == false) then
    -- Gestion de la gravité
    if(collision == false) then
      Lander.vy = Lander.vy + (0.6 * dt)
    else
      Lander.vy = 0
    end
    -------------------------------------
    
    if love.keyboard.isDown("right") then
      Lander.angle = Lander.angle + 90 * dt
      if(Lander.angle > 360) then
        Lander.angle = 0
      end
    end
    if love.keyboard.isDown("left") then
      Lander.angle = Lander.angle - 90 * dt
      if(Lander.angle < 0) then
        Lander.angle = 360
      end
    end
    if love.keyboard.isDown("up") then
      if(carburant > 0) then 
        Lander.engineOn = true
        sonEngine:play()
        local angle_radian = math.rad(Lander.angle)
        local force_x = math.cos(angle_radian) * (Lander.speed * dt)
        local force_y = math.sin(angle_radian) * (Lander.speed * dt)
        
        --Limitation de la vitesse
        if(Lander.vx < 5) then
          Lander.vx = Lander.vx + force_x
        end
        if(Lander.vy < 5) then
            Lander.vy = Lander.vy + force_y
        end
        carburant = carburant -1
      -------------------------------------------------
      end
    else
      Lander.engineOn = false
    end
    
    Lander.x = Lander.x + Lander.vx
    Lander.y = Lander.y + Lander.vy
    
    --Permet au vaisseau de passer d'un bord de l'écran à l'autre
    if(Lander.x >= largeur) then
        Lander.x = (0)
    end
    
    if(Lander.x < 0) then
      Lander.x = largeur
    end
    -------------------------------------------------------------
    
    --Collision
    if(Lander.x >= Plateform.x) 
      and (Lander.x <= (Plateform.x + Plateform.largeur))
    and (Lander.y + Lander.hauteurImg/2 >= Plateform.y)
      and (Lander.y + Lander.hauteurImg/2 <= (Plateform.y + Plateform.hauteur))then
      collision = true
      Lander.y = Plateform.y - Lander.hauteurImg/2

      if(Lander.angle >= 265) and (Lander.angle <= 275) and (Lander.vy < 2) and (Lander.vx < 2) then
        gagne = true
        fini = true
        sonSucces:play()
      else
        perdu = true
        fini = true
        sonExplosion:play()
      end
      
    end
    
    if(Lander.y >= hauteur - (Lander.hauteurImg /2)) then
      Lander.y = hauteur - (Lander.hauteurImg /2)
      collision = true
      perdu = true
      fini = true
      sonExplosion:play()
    end
    
      ----------------------------------------------------------
  end
end

function love.draw()
  love.graphics.draw(background)
  love.graphics.draw(Lander.img, Lander.x, Lander.y, math.rad(Lander.angle), 1, 1, Lander.img:getWidth()/2, Lander.img:getHeight()/2)
  
  
  love.graphics.rectangle("fill",Plateform.x,Plateform.y,Plateform.largeur,Plateform.hauteur)
  
  if Lander.engineOn then
    love.graphics.draw(Lander.imgEngine, Lander.x, Lander.y, math.rad(Lander.angle), 1, 1, Lander.imgEngine:getWidth()/2, Lander.imgEngine:getHeight()/2)
  end
  
  if (perdu == true) and (fini == true) then
    love.graphics.printf("Perdu",0,0.25 *hauteur,largeur,"center")
    love.graphics.printf(sRestart,0,0.5*hauteur,largeur,"center")
  end
  
  if(gagne == true) and (fini == true) then
    love.graphics.printf("Gagné",0,0.25 * hauteur,largeur,"center")
    love.graphics.printf(sRestart,0,0.5 * hauteur,largeur,"center")
  end
  
  if(start == false) and (fini == false) then
    love.graphics.printf(sStart,0,0.5 * hauteur,largeur,"center")
  end
  
  love.graphics.print("Carburant : "..tostring(carburant))
  
  local sDebug = "x : "..tostring(Lander.x)
  sDebug = "x : "..tostring(largeur).." "..tostring(hauteur)
  --love.graphics.print(sDebug)
end