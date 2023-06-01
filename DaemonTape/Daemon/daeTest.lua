engine.name = 'Dae2'





function key(n,z)
  if n == 3 and z == 1 then
    playing = not playing
    mults:reset() -- resets 'mults' index to 1
    redraw()
  end
end


function enc(n,d)
  if n==2 then
    if param_sel == 0 then
      cutoff_param = cutoff_param + d * 0.01
      cutoff_param2 = util.clamp(cutoff_param,1, 5)
      engine.attack(cutoff_param)
      -- print(cutoff_param, d)
      redraw()
    elseif param_sel == 1 then
      res_param = res_param + d * 0.01
      engine.resonance(res_param)
      redraw()
    elseif param_sel == 2 then
      sd_param = sd_param + d * 0.01
      engine.sub_div(sd_param)
      redraw()
    end
      
  elseif n == 3 then
    params:delta("clock_tempo", d)
    redraw()
  elseif n == 1 then
    param_sel = ((param_sel +d) % 3)
    
    redraw()
  end
  
  
  
end





function redraw()
  screen.clear()
  screen.move(64,32)
  screen.text(playing and "K3: turn off" or "K3: turn on")
  screen.move( 64, 40)
  screen.level(5)
  screen.text("cutoff" .. " " .. cutoff_param)
  screen.move( 64, 50)
  screen.level(5)
  screen.text("resonance" .. " " .. res_param)
  screen.move( 64, 60)
  screen.level(5)
  screen.text("subdiv" .. " " .. sd_param)
  screen.move( 64, 10)
  screen.text(params:get("clock_tempo"))
  screen.move( 0, 10)
  screen.text(param_sel)
  
  if param_sel == 0 then
      screen.move( 64, 40)
      screen.level(15)
      screen.text("cutoff" .. " " .. cutoff_param)
  elseif param_sel == 1 then
      screen.move( 64, 50)
      screen.level(15)
      screen.text("resonance" .. " " .. res_param)
  elseif param_sel == 2 then
      screen.move( 64, 60)
      screen.level(15)
      screen.text("subdiv" .. " " .. sd_param)
    
  end
  
  
  screen.update()
end