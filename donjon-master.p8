pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--cursormenu
local global_hud ={
		cursor = {
		x=30 ,
		y=16,
		sprite = 93
		},
		cadre ={
			no_select =138,
			select =141
		},
		hero_icon={
			curent_info ="",
			mage = {
				sprite =3 ,
				cadre_curent = 138 ,
				name = "mage",
				info ={
					en= "todo:write info",
					fr= "todo:write info"
				}
			},
			theif = {
				sprite=5,
				cadre_curent = 138 ,
				name = "theif",
				info = {
					en="todo:write info",
					fr="todo:write info"
				}
			}
		}
	}

--hero
local myhero = { 
	type="" ,
	info={} ,
	is_generate = false

	}

--time game
local time = {
		gameover=5 ,
		flach_texte = 0 ,
		boxdial =0 ,
		xp={
			xp_time_texte=0 ,
			xp_number = 0 ,
			x=0,
			y=0
		}
	}
	function time.flach_text()
		if time.flach_texte >1 then
			time.flach_texte =0
		else
			time.flach_texte +=0.02
		end	
			return time.flach_texte	
	end 
--item
local item={
	selection = false ,
	sprite = 0 ,
	texte ="",
	time =0,
	xp =25
	}

--screen parametre and info
local screen = {
	--info
	state="",
	width = 128 ,
	height=128,
	--camera
	camera = {
		x=0,
		y=0,
		shake_intensity = 4 ,
		time_shake = 0
		},
	black_screen ={
		is_active = false,
		color = 0,
		timer = 0
		}

	}

--liste actor game
local actor_list={}
--liste particule 
local particule_list={}

--liste enemies
local enemies = {
	list={},
	projectiles ={},
	xp ={
		eye = 50 ,
		gerier =100,
		boss =1000
		}
	}
--dialogue boxe
local box_message ={
	message="",
	texte_offset =0
	}

local old_direction_player = {
	x=0 ,
	y=0
	}

--player info 
local player = {
	info={
		--state max player
		max_life = 4,
		max_power = 3 ,
		type_power ="",
		max_xp = 200,
		curent_xp = 0,
		max_lvl = 10,
		lvl =1,
		multiplicateur = 1,
		--liste projecticle player
		projectile_list ={},
		--type character player (babare,mage,ninja)
		characther={}
		
	}
}
player.time={
		delay_attack =0,
		flach =0
	}
--choice pissible to player
player.	choice = {
		is_make_a_choice = false,
		is_bead = false,
		is_chop = false
	} 
--position player in the donjon
player.info.donjon_position = {
	x=0,
	y=0
}
--old postion player in the donjon 
player.info.old_donjon_position = {
	x=0,
	y=0
	}

--life player info 
player.info.number_demie_coeur = 0
--save old position player 
player.info.oldpos= {
	x=0,
	y=0,
	sprite = 93
	}


--donjon parametre state and info
local donjon = {
	info={
		number_room={
			h=4,
			l=10
			},
		number_roomactive = 10
		},
		--list room
		generate={

		}
	}

--language info
language={
	curent = "en"
}

function _init()
    --start game on main menu
	screen.state = "language_selection"
end

function rezet(p_type)

	--type possible: partial - donjon_complet - gameover
	local type = p_type
	--partial : when change room
	if type == "change_lvl" then 

		clear_all_projectiles()
		clear_all_particule()
		clear_all_enemies()
	end
	-- when gameover
	if type == "gameover" or type == "donjon_complet" then 

        clear_all_projectiles()
	    clear_all_enemies()
		clear_all_particule()

		
		--browse list actor
		for a in all(actor_list) do
			--if type different equal hero	
			if a.type~="hero" then
				--destroy	
				a.dell = true
					
			end
        
		end
        --fixe time texte
        time.xp.xp_time_texte = 0
        --fixe multiplicator hero
        player.info.multiplicateur = 1
	end
	-- if player completed donjon
	if type == "donjon_complet" then 

		player.character = {}
		donjon.generate = {}
		myhero.info = {}
		actor_list = {}
        --return to main menu
        screen.state = "main_menu"
	end
	
end

function clear_all_projectiles()

    --destroy projectiles player
    for p in all (player.projectile_list) do

        p.dell = true
		
    end 
    --destroy projectiles enemies
    for p in all (enemies.projectiles) do

        p.dell = true

    end
    --clear all liste projectiles
    enemies.projectiles = {}
    player.projectile_list = {}
end

function clear_all_enemies()

    --dell all enemies
    for enemies in all (enemies.list) do
        if enemies ~=nul then
            enemies.dell = true;
        end    

    end
    --clear liste
   enemies.list={}

end
function clear_all_particule()

    for particule in all (particule_list) do
        particule.dell = true
    end
	particule_list={}
end
--management particule time and destroy
function update_particule()
	

	for i = #particule_list,1,-1 do
		local particule = particule_list[i]	

		if particule.time <= 0 then

			particule.dell = true;
			del(particule_list,particule)
		else
			particule.time -= 0.3
		end
	end
end

function _update()

	if screen.state == "language_selection" then
		--arow hup
 		if btnp(2,0) then
 
			if global_hud.cursor.y>16 then
			
				global_hud.cursor.y-=24
				language.curent ="en"
			else
			
				global_hud.cursor.y = 40
				language.curent ="fr"
					
			end			
			--arow down		
		elseif btnp(3,0)then
 
 			if global_hud.cursor.y<40 then
 		
		  		global_hud.cursor.y+=24
				language.curent ="fr"		
			else
				global_hud.cursor.y = 16
				language.curent ="en"			
			end

		end
		if btnp(5,0) then

 			screen.state = "main_menu"

   		end
	elseif screen.state == "menu_selection" then
		
		--arow hup
 		if btnp(2,0) then
 
			if global_hud.cursor.y>16 then
			
				global_hud.cursor.y-=24
			else
			
				global_hud.cursor.y = 40
					
			end			
			--arow down		
		elseif btnp(3,0)then
 
 			if global_hud.cursor.y<40 then
 		
		  		global_hud.cursor.y+=24		
			else
				global_hud.cursor.y = 16			
			end
 	
		end
		--change cadre color
		if global_hud.cursor.y == 16 then
			global_hud.hero_icon.mage.cadre_curent = global_hud.cadre.select
			global_hud.hero_icon.theif.cadre_curent = global_hud.cadre.no_select
			if language.curent == "en" then
				global_hud.hero_icon.curent_info = global_hud.hero_icon.mage.info.en
			else
				global_hud.hero_icon.curent_info = global_hud.hero_icon.mage.info.fr
			end	
		else
			global_hud.hero_icon.mage.cadre_curent = global_hud.cadre.no_select
			global_hud.hero_icon.theif.cadre_curent = global_hud.cadre.select
			if language.curent == "en" then
				global_hud.hero_icon.curent_info = global_hud.hero_icon.theif.info.en
			else
				global_hud.hero_icon.curent_info = global_hud.hero_icon.theif.info.fr
			end		
		end	


 		--difine type character
 		if btnp(5,0) then

 			if global_hud.cursor.y == 16 then

 				myhero.type = "mage"
 			
 			elseif global_hud.cursor.y == 40 then

 				myhero.type = "thief"
 		
 			end
 			--generate characternnage
 			generate_hero(myhero.type)
 		
 			screen.state = "menu_fiche_character"
   		end
			
	elseif screen.state == "menu_fiche_character" then
		--key x
		if btnp(4,0) then
            --change state character
			generate_hero(myhero.type)
			
        --key y    
		elseif btnp(5,0) then
			--initialisation player	
			player_init()
            --generate donjon 
			generate_donjon()
            --change screen
			screen.state ="gameplay"	
				
		end
			
	elseif screen.state == "main_menu" then		
        --key c
		if btnp(4,0) then
            --change screen    
			screen.state = "menu_selection"

		end

	elseif screen.state == "gameplay" then
	
		player_update()
		item_random_selection()
		actor_update()
        --check collision projectile
		coll_projectiles_test ()
		update_particule()
        --if player dead
		if player.info.life <=0 then

			rezet("gameover")
            --change screen
			screen.state = "gameover"
		end
	
	elseif screen.state == "gameover" then
		--key c 				
		if btn(5,0) and time.gameover <= 0  then
            --add default number life player
			player.info.life = 3	

            --positione player last room clear 
			player.info.donjon_position.x = player.info.old_donjon_position.x
			player.info.donjon_position.y = player.info.old_donjon_position.y		
			
            --rezet time game over 			
			time.gameover = 5
	
			--center player in room
			player.character.x = 60
			player.character.y = 76
            --change screen
			screen.state = "gameplay"
	
		end
        --time gameover update 
		if time.gameover > 0 then
				
			time.gameover -= 0.05
			
		elseif time.gameover <= 0 then
				
			time.gameover = 0
		end
    --if player complet donjon
	elseif screen.state == "winner" then
        --key x
		if btnp (4,0) then

			rezet("donjon_complet")
            --change screen
			screen.state = "main_menu"
		end
	end
end
--draw screen
function _draw()
 	
    --clear screen
    cls()
    
 	if screen.state ~= "gameplay" and screen.state ~= "winner" then
		
        draw_menu()
 	
    elseif screen.state == "gameplay" then

		if screen.black_screen.is_active == false then
			draw_room()
			draw_door()
			draw_chest()
			draw_hud()
			draw_minimap()	
			draw_item(item.sprite,item.texte)
			draw_dial_box()
			draw_actor()
			draw_xp ()
			camera_shake ()
			return
		end	
		--timer black screnne is active 
		if screen.black_screen.timer <=0 then

			screen.black_screen.is_active = false
			screen.black_screen.timer = 0
		else
			screen.black_screen.timer -=0.05
		end

	elseif screen.state == "winner" then

		draw_menu()
		draw_room()
		draw_door(room)
		draw_chest(room)
		draw_hud()
		draw_minimap()
		draw_actor()
 	end

end


-->8
function give_point_to_player()

	time.xp.xp_time_texte = 3
	time.xp.xp_number = enemies.xp.eye * player.info.multiplicateur	
	player.info.curent_xp += enemies.xp.eye * player.info.multiplicateur
	player.info.multiplicateur += 0.5
	check_lvl ()
end

function generate_hero(type)
    
    statecharacter ={}

	if type == "mage" then
        statecharacter.maxstrength = 10 
        statecharacter.maxintelligence = 50
        statecharacter.maxagility = 10
        statecharacter.maxage = 30
 		
 	elseif type == "theif" then

        statecharacter.maxstrength = 20 
        statecharacter.maxintelligence = 10
        statecharacter.maxagility = 50
        statecharacter.maxage = 30
 	end

     state_init(type,statecharacter.maxstrength,
     statecharacter.maxintelligence,
     statecharacter.maxagility,
     statecharacter.maxage
     )
end

function state_init( type , p_strength , p_intelligence , p_agility , p_age )

	hero={}
	hero.type = type
    --define sprite character
	if type == "mage" then

		hero.sprite = 35	

	elseif type == "thief" then

		hero.sprite = 37	

	end
    --define state character
	hero.strength = flr(rnd(p_strength))
	hero.intelligence = flr(rnd(p_intelligence))
	hero.agility = flr(rnd(p_agility))
	hero.age = flr(rnd(p_age))

	if hero._type=="mage" then
		if hero.intelligence<20 then

			hero.intelligence =20

		end
	end

	if hero._type=="thief" then

		if hero.agility<20 then

			hero.agility =20

		end
	end

	if hero.age<15 then

		hero.age =15

	end

	myhero.info = hero
	myhero.is_generate = true
end
-->8



function generate_donjon()
	
	for h = 1 , donjon.info.number_room.h do
	
		donjon.generate[h] = {}

		for l = 1 , donjon.info.number_room.l do
		
			donjon.generate[h][l] = {}
		
			local room = donjon.generate[h][l]
		
		 	room.active =false

			--generate doors
			room.door = {}
 			room.door.left=generate_door("left")
 			room.door.right=generate_door("right")
 			room.door.hup=generate_door("hup")
 			room.door.down=generate_door("down")
 		
 			--define property room
 			room.beginning =false
 			room.boss =false
			room.id_room =-1
            --define enemies type and number
 			room.enemies_type =flr(rnd(3))
 			room.enemies_number =flr(rnd(4))
            --define property default room
 			room.isvisit=false
  			room.active = false
            room.clear = false ;  
  	
  		end
	end
	correction_room()
end

function correction_room()

    
	local roombeginning = false
	--random to define room beginning
	local room_position={}
    room_position.y = flr( rnd( donjon.info.number_room.h ) + 1 )
	room_position.x = flr( rnd( donjon.info.number_room.l ) + 1 )

	--define star position player
	player.info.donjon_position.y =room_position.y
	player.info.donjon_position.x = room_position.x


	player.info.old_donjon_position.x = room_position.x
	player.info.old_donjon_position.y = room_position.y

	--define romm beginning
	donjon.generate[room_position.y][room_position.x].beginning = true
	donjon.generate[room_position.y][room_position.x].active = true
	donjon.generate[room_position.y][room_position.x].enemies_number = 0
	donjon.generate[room_position.y][room_position.x].id_room = 1
	
	--generate chest beginning room
    --5 max chest in the room
	chest_generate(5,donjon.generate[room_position.y][room_position.x])

 	for i = 1 , donjon.info.number_room.h do

		local a = 0
		for a =1 , donjon.info.number_room.l do

            --randon define direction
			-- 0 = hup , 1 = left , 2 = down , 3 = right
		 	local direction = flr( rnd( 4 ) )
			
            --if direction egale hup
			if direction == 0 then
                --if room hup is not active 
				if room_position.y > 1 and donjon.generate[room_position.y-1][room_position.x].active == false then

					donjon.generate[room_position.y][room_position.x].door.hup.active = true
			
					room_position.y -= 1
					a = 10

					donjon.generate[room_position.y][room_position.x].door.down.active = true
					donjon.generate[room_position.y][room_position.x].active = true
					donjon.generate[room_position.y][room_position.x].id_room =define_id_room()
					
					chest_generate( 2 , donjon.generate[room_position.y][room_position.x])
	 			
	  			end
            --if direction == left
			elseif direction == 1 then

				if room_position.x > 1 and donjon.generate[room_position.y][room_position.x-1].active == false then

	  				donjon.generate[room_position.y][room_position.x].door.left.active = true
				
					room_position.x -= 1
					a = 10
			
					donjon.generate[room_position.y][room_position.x].door.right.active = true
					donjon.generate[room_position.y][room_position.x].active = true	
					donjon.generate[room_position.y][room_position.x].id_room = define_id_room()

					chest_generate(2,donjon.generate[room_position.y][room_position.x])
				
	  			end
            --if direction egale down      
			elseif direction == 2 then
			
	  			if room_position.y < 4 and donjon.generate[room_position.y+1][room_position.x].active == false then

					donjon.generate[room_position.y][room_position.x].door.down.active = true
				
					room_position.y += 1
					a = 10
			
					donjon.generate[room_position.y][room_position.x].door.hup.active = true
					donjon.generate[room_position.y][room_position.x].active = true
					donjon.generate[room_position.y][room_position.x].id_room = define_id_room()

					chest_generate(2,donjon.generate[room_position.y][room_position.x])
	  			
	   			end	
             --if direction right      		
			elseif direction == 3  then

				if room_position.x < 10 and donjon.generate[room_position.y][room_position.x+1].active == false then

	 				donjon.generate[room_position.y][room_position.x].door.right.active = true
				
					room_position.x += 1
					a = 10
				
					donjon.generate[room_position.y][room_position.x].door.left.active=true
					donjon.generate[room_position.y][room_position.x].active=true
					donjon.generate[room_position.y][room_position.x].id_room = define_id_room()

					chest_generate(2,donjon.generate[room_position.y][room_position.x])
	 			
	  			end
		    end 
		end
		if i >=donjon.info.number_room.h then
			--last room is room boss
			donjon.generate[room_position.y][room_position.x].active = true
			donjon.generate[room_position.y][room_position.x].boss =true
			donjon.generate[room_position.y][room_position.x].id_room = 0
			chest_generate(4,donjon.generate[room_position.y][room_position.x])

		end
	end

end
function define_id_room()
    --define id room
    local room_id = flr( rnd( 9 ) )
    -- 1 reserved beginning 0 reserved boss
	while room_id <=1 do

		room_id = flr( rnd( 9 ) )
	end
	return room_id
end
function generate_door(p_direction)

	local door={active = false , loked=false}
	--define position door in the room
	if p_direction == "hup" then
		door.x = 60
		door.y = 32
	elseif p_direction == "left" then
		door.x = 0
		door.y = 76
	elseif p_direction == "down" then
		door.x = 60
		door.y = 120
	elseif p_direction == "right" then
		door.x = 120
		door.y = 76
	end	
	return door
end

--define romm beginning and room boss
function beginning_boss()

	local beginning = 0
	local boss = 0

	for h = 1 , donjon.info.number_room.h do

		for l = 1 , donjon.info.number_room.l do

			if beginning == 0 and 	donjon.generate[h][l].active  then
			
				donjon.generate[h][l].beginning = true
				beginning = 1
				
			elseif donjon.generate[h][l].active	then
		
				donjon.generate[h][l].boss = true
				donjon.generate[th][tl].boss = false

			end
		end
	end
end

function chest_generate(p_numberchest,p_room)

	local number = flr(rnd(p_numberchest))
	p_room.chest = {}

	for i = 1 , number do
		p_room.chest[i] = {}
		p_room.chest[i].unlock = false

		if i == 1 then
			--hup-left
			p_room.chest[i].x = 8
			p_room.chest[i].y = 48
			
		elseif i == 2 then
			--hup-right
			p_room.chest[i].x = 112
			p_room.chest[i].y = 48
			
		elseif i == 3 then
			--down left
			p_room.chest[i].x = 8
			p_room.chest[i].y = 112
			
		elseif i == 4 then
			--down right
			p_room.chest[i].x = 112
			p_room.chest[i].y = 112
			
		end
	end
end

-->8

function item_random_selection()

 	if item.selection then
 	
 		local id = flr(rnd(3))


 		if id == 0 then
 	
 			item.sprite = 24
 			item.texte = "the life potion"

			if player.info.life < player.info.max_life then
				player.info.life += 2
				if player.info.life > player.info.max_life then
					player.info.life = player.info.max_life
					
				end	
			else
				time.xp.x = player.character.x
				time.xp.y = player.character.y
				time.xp.xp_time_texte = 3
				time.xp.xp_number = item.xp	* player.info.multiplicateur
				player.info.curent_xp += item.xp * player.info.multiplicateur
				check_lvl ()
			end

 		elseif id == 1 then

 			if myhero.type == "mage" then

				item.sprite = 25
 				item.texte =	"the mana potion"
			
			elseif myhero.type == "thief" then

				item.sprite = 14
 				item.texte =	"the knife"
			end

			give_xp_player()

 		elseif id == 2 then
 	
 			item.sprite = 7
 			item.texte = "the half heart"

			if player.info.max_life < 8 then

				player.info.number_demie_coeur += 0.5

				if player.info.number_demie_coeur >= 1 then

					player.info.number_demie_coeur = 0
					player.info.max_life += 2

					if player.info.max_life >8 then

						player.info.max_life = 8

					end	

				end
			end
 		end
 		item.time = 60
 		item.selection = false
	end
end

-->8

function give_xp_player()
    if player.info.power < player.info.max_power then

        player.info.power += 1

        if player.info.power > player.info.max_power then

            player.info.power = player.info.max_power

        end
    else

        time.xp.x = player.character.x
        time.xp.y = player.character.y
        time.xp.xp_time_texte = 3
        time.xp.xp_number = item.xp	* player.info.multiplicateur

        player.info.curent_xp += item.xp	* player.info.multiplicateur

        check_lvl ()
    end
end

function player_init()

	player.character={}
	player.character = generate_actor(60,60,"hero","player")
	
	player.character.anim.walk={}
	player.character.anim.attack ={}
	player.character.anim.idle={}
	player.character.speed = 0.75

 	player.info.life = 4
 	player.info.key = 3
 	player.info.power = 2

 	player.info.projectile_direction = 0

	if myhero.type == "barbare" then
		
		player.character.anim.walk.left={34,50}
		player.character.anim.walk.hup={33,49}
		
		player.character.anim.attack.left={65,81}
		player.character.anim.attack.hup={64,80}
		
		player.character.anim.idle.left={97,113}
		player.character.anim.idle.hup={96,112}

		player.character.power_sprite = {12,11,10}
		player.info.type_power = " rage "
		
	elseif myhero.type == "mage" then
	
		player.character.anim.walk.left={36,52}
		player.character.anim.walk.hup={35,51}
		
		player.character.anim.attack.left={67,83}
		player.character.anim.attack.hup={66,82}
	
		player.character.anim.idle.left={99,115}
		player.character.anim.idle.hup={98,114}

		player.character.power_sprite = {28,27,26}
		player.info.type_power = " mage "
	
	elseif myhero.type == "thief" then
	
		player.character.anim.walk.left={38,54}
		player.character.anim.walk.hup={37,53}
		
		player.character.anim.attack.left={69,85}
		player.character.anim.attack.hup={68,84}
		
		player.character.anim.idle.left={101,117}
		player.character.anim.idle.hup={100,116}

		player.character.power_sprite = {77,76,75}
		player.info.type_power = " chie "

	
	end
	
	player.character.anim.state = "idle_hup"

	player.character.direction.x = -1
	player.character.direction.y = 0 
end

function player_update()
	if(player.choice.is_make_a_choice == false) then

		player_input_move()
		player_input_attack()
	else
		if player.choice.is_bead then
			if btnp(4,0)then
				screen.black_screen.is_active = true
				screen.black_screen.timer = 1
				player.choice.is_bead = false
				player.choice.is_make_a_choice = false
				time.boxdial = 0
				return
			end	
			if btnp(5,0) then
				player.choice.is_bead = false
				player.choice.is_make_a_choice = false	
				time.boxdial = 0
				return
			end		

		elseif player.choice.is_chop then


		end

	end
end

function player_input_move()

	player.info.oldpos.x = player.character.x
	player.info.oldpos.y = player.character.y

	local p ={
		x = player.character.x,
		y = player.character.y
		}

	if btn(0,0) then
	
		p.x -= 8
		check_door(p)
	
		player.character.fliph = false
	
		player.character.anim.state = "walk_left"	

		player.character.direction.x = -1
		player.character.direction.y = 0 

	elseif btn(1,0) then	
		
		p.x += 8
		check_door(p)
		
		player.character.fliph = true
		
		player.character.anim.state = "walk_left"

		player.character.direction.x = 1
		player.character.direction.y = 0

	elseif btn(2,0) then
		
		p.y -= 8	
		check_door(p)
		
		player.character.flipv = false
		
		player.character.anim.state = "walk_hup"
		
		player.character.direction.x = 0
		player.character.direction.y = -1

	elseif btn(3,0) then		
		
		p.y += 8
		check_door(p)

		player.character.anim.state = "walk_hup"
		player.character.flipv = true
		player.character.direction.x = 0
		player.character.direction.y = 1
		
	elseif btn(5,0) == false   then

		if player.character.direction.y~=0 then

			player.character.anim.state = "idle_hup"
		
		elseif player.character.direction.x~=0 then

			player.character.anim.state = "idle_left"
		end

		player.character.direction.x = 0
		player.character.direction.y = 0

	end

	if player.character.direction.x ~=0 or player.character.direction.y~=0 then
	
		old_direction_player.x = player.character.direction.x
		old_direction_player.y = player.character.direction.y
	
	end

end

function player_input_attack()

	if btn(5,0) then

		player.time.delay_attack += 0.05

		if player.time.delay_attack >= 1 then

 			local sprite_projectile = {}
 	
 			if myhero.type == "mage" then
 		
 				sprite_projectile = {59,39}
 	
 			elseif myhero.type == "thief" then
 		
 				sprite_projectile = {58}
 			end

			local temp_pos = {}
			temp_pos.x = player.character.x
			temp_pos.y = player.character.y

			local projectile = generate_actor(temp_pos.x,temp_pos.y,"projectile","projectile_player")
			if player.character.direction.x > 0 then
				projectile.fliph = true
			elseif player.character.direction.y > 0 then
				projectile.flipv = true
			end

			projectile.direction.x = old_direction_player.x
			projectile.direction.y = old_direction_player.y 		
 			
			projectile.anim.state = ""
 			projectile.sprite = sprite_projectile
			player.time.delay_attack = 0
		
			add(player.projectile_list,projectile)
		end

	elseif player.time.delay_attack  > 0.3 then
		
		player.time.delay_attack  = 1	

	end
end

function check_door(p_player)
	
	local room = donjon.generate[player.info.donjon_position.y][player.info.donjon_position.x]

    local next_room={
		position={
			x = player.info.donjon_position.x ,
			y = player.info.donjon_position.y 
			}
		}

    local new_position_player={
		x = player.character.x ,
		y = player.character.y
		}


	if room.enemies_number > 0 then
		return ;
	end

	if check_collision(p_player, room.door.hup) and room.door.hup.active  then
	
		next_room.position.y -= 1
		new_position_player.y = 110

		player.info.oldpos.y =100
	elseif  check_collision(p_player, room.door.left) and room.door.left.active  then
	
		next_room.position.x -=1
		new_position_player.x = 110

	elseif  check_collision(p_player, room.door.down) and room.door.down.active then

		next_room.position.y +=1
		new_position_player.y = 50
		player.info.oldpos.y=50
	elseif  check_collision(p_player, room.door.right) and room.door.right.active  then
			
		next_room.position.x +=1
		new_position_player.x = 10

	end

	if player.info.donjon_position.x ~= next_room.position.x then

		change_the_room("horizontal",next_room,new_position_player)

	elseif player.info.donjon_position.y ~= next_room.position.y then

		change_the_room("vertical",next_room,new_position_player)

	end	
 		
end

function change_the_room( p_axe_change , p_next_room , p_new_position_player )

    player.info.old_donjon_position.x = player.info.donjon_position.x
    player.info.old_donjon_position.y = player.info.donjon_position.y

    if(p_axe_change =="horizontal") then

        player.info.donjon_position.x = p_next_room.position.x
        player.character.x = p_new_position_player.x


    elseif (p_axe_change == "vertical") then

        player.info.donjon_position.y = p_next_room.position.y
        player.character.y = p_new_position_player.y

    end

    rezet( "change_lvl")

    spawn_enemies()
end

function check_lvl ()

	if player.info.curent_xp >= player.info.max_xp and player.info.lvl < player.info.max_lvl  then

  
		local xpexcess = player.info.curent_xp - player.info.max_xp 

        player.info.curent_xp = xpexcess

		player.info.max_xp = player.info.max_xp * 2

		player.info.lvl += 1

        if player.info.lvl > player.info.max_lvl then

			player.info.lvl = player.info.max_lvl
		end	
	end
end


function check_chest_col (p_chestv)

	if check_collision(player.character,p_chestv) then
 
  		if p_chestv.unlock == false and player.info.key > 0 then
  
  			p_chestv.unlock = true
  			item.selection = true
			player.info.key -= 1
		
		elseif p_chestv.unlock == false and player.info.key <= 0 then

			box_message.message = "you not have key"

			time.boxdial = 1

 		end
 	end
end


-->8



function check_collision_map(p_acteur,p_flag)

  	local ct=false

	local p_room = donjon.generate[player.info.donjon_position.y][player.info.donjon_position.x]
	local offset = 16* p_room.id_room 
	offset = offset*8

    local x1=(p_acteur.x+offset)/8
    local y1=(p_acteur.y)/8
    local x2=((p_acteur.x+offset)+7)/8
    local y2=(p_acteur.y+7)/8

    local a=fget(mget(x1,y1),p_flag)
    local b=fget(mget(x1,y2),p_flag)
    local c=fget(mget(x2,y2),p_flag)
    local d=fget(mget(x2,y1),p_flag)
    ct=a or b or c or d

  	return ct
end

function check_collision(a1, a2)

  return (a1.x) < a2.x+(8/2) and
	a2.x < (a1.x)+(8/2) and
	a1.y < a2.y+(8/2) and
	a2.y < (a1.y+4)+(8/2)

end

function generate_actor( p_position_x , p_position_y , p_type , p_tag )

	if p_tag == nul then
		p_tag ="no define"
	end

	local actor={}

	actor.type = p_type
	actor.tag = p_tag

	actor.x = p_position_x
	actor.y = p_position_y
	actor.speed = 0.75
	
	actor.direction = {}
	actor.direction.x = 0
	actor.direction.y = 0

	actor.flipv = false
	actor.fliph = false

	actor.sprite = {}
	actor.curent_frame = 1

   
	actor.anim={}
	actor.anim.state = "idle_hup"
	actor.anim.speed = 0.1

	actor.dell = false
 
	actor.delay_attack = 0
	actor.spawn_test_collision = false
 
	add(actor_list,actor)

	return actor

end


function coll_projectiles_test ()
	
	local room = donjon.generate[player.info.donjon_position.y][player.info.donjon_position.x]
 
	for enemy in all (enemies.list) do
  
  		for projectile_player in all (player.projectile_list)do	

			if check_collision(enemy, projectile_player) and enemy.dell == false and projectile_player.dell == false then

				if enemy.type == "enemy" then	

					enemy.life -= 1 * ( player.info.power + 1 )
					projectile_player.dell = true

					if enemy.life <= 0 then
						
						enemy.dell = true

						del( enemies.list , enemy )

						generate_particules( 20 , 10 , enemy.x , enemy.y )

						room.enemies_number -= 1
						
						
						check_win (room)

						local id = flr( rnd( 3 ) )

						if id == 0  and player.info.key < 4 then

							box_message.message = " you not have key"
							box_message.texte_offset = 16
							time.boxdial = 2

							player.info.key += 1

						elseif player.info.key > 4 then

							player.info.key = 4	
						end
					end
	
					generate_particules(8 , 10 , projectile_player.x , projectile_player.y)

					del( player.projectile_list , projectile_player )	
				end	
			elseif projectile_player.dell then

				del( player.projectile_list , projectile_player )	
			end
  		end
 	end

  	for projectile_enemy in all ( enemies.projectiles )do

	  	if projectile_enemy.dell == false then		

			if check_collision( projectile_enemy , player.character ) then
				
				applique_domage_player()


				projectile_enemy.dell=true
	
				generate_particules(4,10,projectile_enemy.x,projectile_enemy.y)
		
				del(enemies.projectiles,projectile_enemy)	
			end
		end
	end
end

function applique_domage_player()

	init_shake_camera(10)

	player.info.life -= 1
 
	player.info.multiplicateur =1

	player.info.power -=1

	if player.info.power < 1 then

		player.info.power = 1
	end


end

function check_win (p_room)

	if p_room.boss then

		if p_room.enemies_number <= 0 then

			screen.state = "winner"
		end	
	end
end

function generate_particules ( p_number_particule , p_color , p_position_x , p_position_y )


	for i = 1 , p_number_particule do
	
		local particule = generate_actor(p_position_x,p_position_y,"particule")
		particule.colore = p_color
		particule.direction.x = rnd( 2 ) - 1
		particule.direction.y = rnd( 2 ) - 1
		particule.time = 1
		particule.dell = false
		add( particule_list , particule )
	end
end

local math={}

function math.dist( x1 , y1 , x2 , y2 )
 
	return ( ( x2 - x1 ) ^ 2 + ( y2 - y1 ) ^ 2 ) ^ 0.5

end

function math.angle( x1 , y1 , x2 , y2 )

	return atan2( y2 - y1 , x2 - x1 ) 

end
-->8



function init_shake_camera (p_duration_shake)
	screen.camera.time_shake = p_duration_shake
end

function camera_shake ()
	if screen.camera.time_shake > 0 then
		screen.camera.x = rnd(2)-1 * screen.camera.shake_intensity
		screen.camera.y = rnd(2)-1 * screen.camera.shake_intensity
		screen.camera.time_shake -= 1
	else
		screen.camera.x = 0
		screen.camera.y = 0

	end	
	camera(screen.camera.x,screen.camera.y)
end

--management hud to screen
function draw_hud()

    --affiche power character
	local powerpourcentage = 0
	if player.info.power <=0 then

		powerpourcentage = 0

	elseif player.info.power  == 2 then

		powerpourcentage = 50

	elseif player.info.power == 3 then

		powerpourcentage = 100

	end

	print(player.info.type_power..powerpourcentage.."%", 88 , 8 , 7 )
	spr( player.character.power_sprite[player.info.power] , 80 , 8 )

	local heartsprite = {}
 	--affiche la vie du jouer 
 	if player.info.life == 1 then

		heartsprite = {7,9,9,9}

	elseif player.info.life == 2 then

		heartsprite = {8,9,9,9}

	elseif player.info.life == 3 then

		heartsprite = {8,7,9,9}
	
	elseif player.info.life == 4 then

		heartsprite = {8,8,9,9}

	elseif player.info.life == 5 then

		heartsprite = {8,8,7,9}

	elseif player.info.life == 6 then
		
		heartsprite = {8,8,8,9}

	elseif player.info.life == 7 then

		heartsprite = {8,8,8,7}

	elseif player.info.life == 8 then
		
		heartsprite = {8,8,8,8}

	end	

	--draw quantity heart
	if player.info.max_life >= 2 then
	
		spr( heartsprite[1] , 88 , 0 )
		
		if player.info.max_life >= 4 then	
	
			spr( heartsprite[2] , 96 , 0 )

			if player.info.max_life >= 6 then	
	
				spr( heartsprite[3] , 104 , 0 )
				if player.info.max_life >= 8 then	
	
					spr(heartsprite[4] , 112 , 0 )
	
				end
			end
		end
	end


	if player.info.max_life >= 8 then	
	
		spr(heartsprite[4] , 112 , 0 )
	
	end
	print(player.info.max_life,0,0)

 --draw number key player 
 	for i=1,player.info.key do
 	
 		local tx = 8 * i
 		spr(47 , 80 + tx , 16)
 
	end

--draw lvl player 
	print("lvl hero:"..player.info.lvl,0,33,7)
	print("xp:"..player.info.curent_xp.."/"..player.info.max_xp,78,33,7)
end


function draw_menu()
	local texte =""
	local texte2 =""

	if screen.state == "language_selection" then
		local texte = "select your language"
		
		print(texte,30,0,7)
		spr(237,2,18,2,2)
		spr(235,2,40,2,2)

		--cursor selection
		spr(
			global_hud.cursor.sprite ,
			global_hud.cursor.x ,
			global_hud.cursor.y,
			2,
			2
			)

	--draw main menu
	elseif screen.state == "main_menu" then
		--titel game
		spr(192,32,18,16,2)
		spr(224,32,36,16,2)
		
		--todo:re factory flcach texte create function manager effect
		local temp_time = time.flach_text()
		if temp_time >= 0.5 and temp_time <1 then
			--action text
			texte = "c access menu"
	
			print(texte,30,90,7)
		end
		--draw characters under the titel
		--barbare
		spr(1,31,54,2,2)
		--mage
		spr(3,50,54,2,2)
		--thief
		spr(5,70,54,2,2)

		--draw menu select character
	elseif screen.state == "menu_selection" then

		--create icon hero in the menu
		--mage
		spr(global_hud.hero_icon.mage.cadre_curent,1,4,3,3)
 		print(global_hud.hero_icon.mage.name,3,26,7)
 		spr(global_hud.hero_icon.mage.sprite,3,7,2,2)
		
		--thief
		spr(global_hud.hero_icon.theif.cadre_curent,1,34,3,3)
 		print(global_hud.hero_icon.theif.name,3,56,7)
 		spr(global_hud.hero_icon.theif.sprite,3,37,2,2)
		--print info hero selected
		rect(125,65,1,102,7)
		print(global_hud.hero_icon.curent_info,4,70)
		--cursor selection
		spr(
			global_hud.cursor.sprite ,
			global_hud.cursor.x ,
			global_hud.cursor.y,
			2,
			2
			)
	
		--log to screen
		local temp_time = time.flach_text()

		if temp_time >= 0.5 and temp_time <1 then

			texte = "press x to vallid \n the characther"
		
			print(texte,30,112,7)
		end	
	
		--draw state player 
	elseif screen.state == "menu_fiche_character" then
			--select sprite character
 		if myhero.type == "mage" then
 		
 			spr(3,25,44,2,2)
 	
 		elseif myhero.type == "thief" then
 		
 			spr(5,25,44,2,2)
 		
 		end

		--draw state
		print(myhero.type , 48 , 32 , 7)
		print("strength = "..myhero.info.strength , 48 , 40 , 7)
		print("intelligence = "..myhero.info.intelligence , 48 , 48 , 7)
		print("agility = "..myhero.info.agility, 48 , 56 , 7)
		print("age = "..myhero.info.age, 48 , 64 , 7)
	
		--draw key
			
			texte = "press c to generate"
			texte2 = "press x to continue"

		print(texte, 0 , 95 , 7)
	
		if time.flach_texte < 30 then

			print(texte2,0,110,7)
	
		elseif time.flach_texte >= 60 then
		
			time.flach_texte =0
	
		end
		time.flach_texte	+= 1

	elseif screen.state == "gameover" then

		rect( 120 , 120 , 0 , 0 , 5 )
		if time.gameover > 0 then

 			print( flr(time.gameover) , 55 , 52 , 7 )
	
		else
			texte = "key ❎ to continue"

			print ( texte , 10 , 75 , 7 )
		end
		print ( "gameover" , 40 , 60 , 7 )

	elseif screen.state == "winner" then

		texte = "donjon clear"
		texte2 = "key x to continu\nmain menu "
	
		print(texte , 10, 80 , 11 )
		print(texte2, 8 , 88 , 11 )	
	end
end


--draw mini map donjon
function draw_minimap()

	local x = 0
	local y = 0
	
	local bloc = 8
	
	for h = 1 , #donjon.generate do
	
		y = (h * bloc) - 8
		
		for l = 1 , #donjon.generate[h] do
		
			local room = donjon.generate[h][l]
		
			x = (l * bloc) - 8
			
			if room.active then
 				if room.isvisit then
  					if room.beginning then
  				
  						spr( 34 , x , y )
  						
  					elseif 	room.boss then
  				
  						spr( 49 , x , y )
  						
  					else
  				
  						spr( 33 , x , y )
  						
  					end
  	
  				
  					--draw door in the mini map
   					if room.door.hup.active then
   						
						spr( 43 , x , y - 4 )
   					end
   			
   					if room.door.left.active then
   						
						spr( 43 , x - 3 , y )
   					end
   			
   					if room.door.down.active then
   						
						spr( 43 , x , y + 3 )
   					end
   			
   					if room.door.right.active then
   						
						spr( 43 , x + 4 , y )
   					end
					--check chests close to the room 
					if h ~= player.info.donjon_position.y or l ~= player.info.donjon_position.x then
						for i = 1 , #room.chest do
							if room.chest[i].unlock == false then

								spr( 31 , x , y)
								i = #room.chest
							end
						end	
					end	
  				end	
                --draw position player in the mini map 
				if h == player.info.donjon_position.y and l == player.info.donjon_position.x then
					
					if room.isvisit == false then
								
						room.isvisit = true
					end
					spr( 42 , x , y )	
				end	
				
			end
			
		end
	end
end


--draw chest 
function draw_chest()
	local p_room = donjon.generate[player.info.donjon_position.y][player.info.donjon_position.x]
	local chestv={}
 
	for i = 1 , #p_room.chest do
	
		chestv = p_room.chest[i]

		if chestv.unlock == false then
		
			spr( 31 , chestv.x , chestv.y-8)
			
		elseif chestv.unlock == true then
		
			spr( 15 , chestv.x , chestv.y-8)
			
		end

 		check_chest_col (chestv) 
 	end
end

--draw the door
function draw_door()

	local p_room = donjon.generate[player.info.donjon_position.y][player.info.donjon_position.x]

	local door = donjon.generate[player.info.donjon_position.y][player.info.donjon_position.x].door
	--hup
 	if door.hup.active then
 		spr( 105 , door.hup.x , door.hup.y-8,1,2)
 			
		if p_room.enemies_number > 0 then
				
			spr( 57 , door.hup.x , door.hup.y)
				
		end
 	end

 	--left
 	if door.left.active then
 		spr( 108 , door.left.x , door.left.y,1,2)
 		
 		if p_room.enemies_number > 0 then
				
			spr( 41 , door.left.x , door.left.y+4)
				
		end
 	end
 	--down
 	if door.down.active then
 		spr( 106 , door.down.x , door.down.y-8,1,2)
 
 		if p_room.enemies_number > 0 then
				
			spr(57,door.down.x,door.down.y)
				
		end
 	end
 	--right
 	if door.right.active then
 		spr( 107 , door.right.x , door.right.y,1,2)
 		
 		if p_room.enemies_number > 0 then
				
			spr( 41 , door.right.x , door.right.y+4)
				
		end
	 end
end

--draw item
function draw_item(p_sprite,p_texte)

 
 	if item.time < 0 then
  	
  		item.time = 0
  		item.sprite = 0
  		p_sprite = 0
  		item.texte = ""
  
	end 
 
 	if item.time > 0  then
	 	--dialogue box
		rectfill(24,110,108,94,0)
		rect(24,110,108,94,10)

 		spr( p_sprite , 60 , 87 )
 		print( p_texte , 56 - 25 , 100 , 7 )
 	
 		if item.time > 0 then
 		
 			item.time -= 1
 	
 		end
 	end
end


function draw_dial_box()

	if time.boxdial < 0 then
  	
  		time.boxdial = 0

	elseif time.boxdial > 0 then

 		--dialogue box
		rectfill(24,126,113,112,0)
		rect(24,126,113,112,10)
 		print( box_message.message , 30 , 114 , 7 )
 		time.boxdial -= 0.02
 	
 	end
end
--draw room
function draw_room()

	local p_room = donjon.generate[player.info.donjon_position.y][player.info.donjon_position.x]
	map( 16* p_room.id_room , 0 )
end

--draw actors
function draw_actor()

	for i=#actor_list,1,-1 do
		local actor = actor_list[i]
		--play animation actor
		actor.curent_frame += actor.anim.speed
		if flr(actor.curent_frame) > #actor.sprite then
			actor.curent_frame = 1
		end

		--move actor
		actor.x	+= actor.direction.x * actor.speed
		actor.y	+=	actor.direction.y * actor.speed

			
		check_actor_collision(actor)

		--check actor is not out of screen
		if( actor.x > 0 and actor.x < screen.width and actor.y > 0 and actor.y < screen.height ) then
			--draw actor
			spr( actor.sprite[ flr(actor.curent_frame) ] , actor.x , actor.y ,1 , 1 , actor.fliph ,actor.flipv )
		end
		--management destroy actor
		if actor.dell  then

			if actor.type == "enemy" then 
			
				time.xp.x = actor.x
				time.xp.y = actor.y
			
				if actor.tag ~= "egg" and actor.life <= 0 then
					give_point_to_player()
				end
			end	
			del(actor_list,actor)
		end
	end
end

function check_actor_collision(actor)

	if actor.type == "projectile" then
		--destroy projectile if collisione with the map	
		if 	check_collision_map(actor,0) or actor.dell == true  then

			generate_particules(8,10,actor.x,actor.y)
			actor.dell = true

		end

	elseif actor.type =="hero" then

		for	flag =0,4 do
			
			local is_collision = check_collision_map(actor,flag)

			--if not collision detected no check to flag 
			if(is_collision == true) then 
				--fixe position player 
				actor.x = player.info.oldpos.x
				actor.y = player.info.oldpos.y
				
				if(flag ==0 ) then
					--collision standar to map 
					return
				elseif (flag == 1) then
					-- collision to bead
					action("bead")
					return
				elseif (flag == 2) then
					--collision to shop
					action("shop")
					return
				end
			end	
		end
	end
end

function action(type_action)

	local texte =""

	if btnp(4,0) then

		if type_action == "bead" then
			texte = "do you want to sleep \n  x yes c no "


			box_message.message = texte
			time.boxdial = 2
			player.choice.is_make_a_choice = true
			player.choice.is_bead = true
			return

		elseif type_action == "shop" then

			texte = "the shop is closed\ncome back later"

			box_message.message = texte
			time.boxdial = 2
			return

		end	
	end
end

function draw_xp ()
	
	if time.xp.xp_time_texte > 0 then
		time.xp.y -= 0.1 
		print( time.xp.xp_number.."xp" , time.xp.x , time.xp.y )
		time.xp.xp_time_texte -= 0.09
	
	elseif time.xp.xp_time_texte < 0 then
		time.xp.xp_time_texte = 0

	end			
end

-->8
function egg_generate(p_position_x,p_position_y)

	local egg = generate_actor(p_position_x,p_position_y,"enemy","egg")
	egg.anim.idle = {}
	egg.anim.idle.hup = { 86 , 87 }
	egg.anim.state = "idle_hup"
	egg.anim.speed = 0.2

	egg.time_action = 3
	egg.speed = 0.5

end


function eye_generate( p_position_x , p_position_y )
	
	local eye = generate_actor( p_position_x , p_position_y ,"enemy","eye" )
	--define animation
	eye.anim.idle = {}
	eye.anim.idle.hup = { 70 , 71 , 72 }
	eye.anim.speed = 0.2
	--define speed move
	eye.speed = 0.5
	eye.enemies_type = 0	--0 egale eye
	--define points life enemies
	eye.life = 3
	--define direction default egale 0 not move
	eye.select_direction =0
	--destination null
	eye.destination = 0
	--eye not move default
	eye.is_move = false
	--add eye list enemies
	add(enemies.list,eye)
end

function actor_update()
	actor_update_animation()

end

--type zombie

function spawn_enemies()
	--recup curent room
	local room = donjon.generate
	[player.info.donjon_position.y]
	[player.info.donjon_position.x]

	--define enemies position variable
	local pos_enemies={x = 0,y = 0}  
	
	--if number enemies superior 0 in the room
	if room.enemies_number >0 then
	
	  	for i = 1 , room.enemies_number do

	  		--define enemies position randomly		
	  		pos_enemies.x = 16 + rnd(80)
	  		pos_enemies.y = 40 + rnd(70)
	  		--todo: when he has more enemies type make a random for select enemies
		  	egg_generate(pos_enemies.x , pos_enemies.y)
		
		end
	end
end

function actor_update_animation()
		
	for actor in all (actor_list) do
		if(actor.dell)then
			break
		end
		if actor.type == "particule" then
			break
		end
		if actor.anim.state == "idle_hup" then
			
			actor.sprite = actor.anim.idle.hup
			enemies.idle(actor)

		elseif actor.anim.state == "idle_left" then

			actor.sprite = actor.anim.idle.left
			enemies.idle(actor)
		elseif actor.anim.state == "walk_hup" then
			
			if actor.sprite ~= actor.anim.walk.hup then
			
				actor.sprite = actor.anim.walk.hup	
			end
			enemies.move(actor)
		elseif actor.anim.state == "walk_left" then
			
			if actor.sprite ~= actor.anim.walk.left then
				actor.sprite = actor.anim.walk.left
			end
			enemies.move(actor)
		elseif actor.anim.state == "attack_hup" then
			
			if actor.sprite ~= actor.anim.attack.hup then
				actor.sprite = actor.anim.attack.hup
			end
			enemies.attack(actor)
		elseif actor.anim.state == "attack_left" then
			
			if actor.sprite ~= actor.anim.attack.left then
				actor.sprite = actor.anim.attack.left
			end
			enemies.attack(actor)
		elseif actor.anim.state == "dead" then
			
			if actor.sprite ~= actor.anim.dead then
				actor.sprite = actor.anim.dead
			end
		end

		--if enemies is type eye
		if actor.tag == "eye" then
			--check distance the player to enemies
			--if the player is within 30 pixels of the enemies
			if math.dist(player.character.x , player.character.y , actor.x ,actor.y) < 30 then
			
				enemies.attack(actor)
				actor.speed = 0
				--if the player is more than 30 pixels from the enemies
			elseif math.dist(player.character.x , player.character.y , actor.x ,actor.y) >= 30 then

				enemies.move(actor)
				actor.speed = 0.5
			end
		end	
		
	end
end

function enemies.move(p_enemy)
	
	if p_enemy.tag == "eye" then
		--when actor sawn check he is not collision with
		--environment
		if p_enemy.spawn_test_collision == false then

			p_enemy.spawn_test_collision = enemies_check_collision (p_enemy)

		else
			--if acotr not move 
			if p_enemy.is_move == false then

				--reminder: 0 not move  1 left 2 right 3 hup 4 down

				--roll dice to decide direction 
				p_enemy.select_direction = flr( rnd( 5 ) )

				if p_enemy.select_direction == 1 then--left

					p_enemy.destination = p_enemy.x - 8
					p_enemy.direction.x = -1 

				elseif	p_enemy.select_direction == 2 then--right

					p_enemy.destination = p_enemy.x + 8
					p_enemy.direction.x = 1
					
				elseif	p_enemy.select_direction == 3 then--hup

					p_enemy.destination = p_enemy.y - 8
					p_enemy.direction.y = -1 

				elseif	p_enemy.select_direction == 4 then--down

					p_enemy.destination = p_enemy.y + 8
					p_enemy.direction.y = 1
					
				elseif	p_enemy.select_direction == 0 then--not move

					p_enemy.select_direction = 1
					p_enemy.destination = p_enemy.x - 8
					p_enemy.direction.x = -1 

				end

				p_enemy.is_move = true
				--if actor move	
			elseif p_enemy.is_move then

				if p_enemy.select_direction == 1 then--left

					if p_enemy.x <= p_enemy.destination then
						
						p_enemy.destination += 8
						p_enemy.direction.x = 1 
						p_enemy.select_direction = 0
					end

				elseif p_enemy.select_direction == 2 then--right
					
					if p_enemy.x >= p_enemy.destination then
						p_enemy.destination -= 8
						p_enemy.direction.x = -1 
						p_enemy.select_direction = 0
					end

				elseif p_enemy.select_direction == 3 then--hup

					if p_enemy.y <= p_enemy.destination then
						p_enemy.destination += 8
						p_enemy.direction.y = 1 
						p_enemy.select_direction = 0
					end
				elseif p_enemy.select_direction == 4 then--down
				
					if p_enemy.y >= p_enemy.destination then
						p_enemy.destination -= 8
						p_enemy.direction.y = -1 * p_enemy.speed
						p_enemy.select_direction = 0
					end

				elseif p_enemy.select_direction == 0 then--not move
					--check is actor move horizontal
					if p_enemy.direction.x ~= 0 then

						if p_enemy.direction.x > 0 then--if move  right

							--if position actor egale or upper position destination
							if p_enemy.x >= p_enemy.destination then

								p_enemy.direction.x = 0
								p_enemy.is_move = false
							end
							
						elseif p_enemy.direction.x < 0 then--if move left

							if p_enemy.x <= p_enemy.destination then

								p_enemy.direction.x = 0
								p_enemy.is_move = false
							end

						end
					--check is actor move vertical
					elseif p_enemy.direction.y ~= 0 then

						if p_enemy.direction.y > 0 then

							if p_enemy.y >= p_enemy.destination then

								p_enemy.direction.y = 0
								p_enemy.is_move = false
							end

						elseif p_enemy.direction.y < 0 then

							if p_enemy.y <= p_enemy.destination then

								p_enemy.direction.y = 0
								p_enemy.is_move = false
							end
						end
					end
				end	
			end 
		end	
	end
end

function enemies.idle(p_enemy)
	--if enemies type egg
	if p_enemy.tag == "egg" and  p_enemy.dell == false then

		--if time egale 0 egg hatching 
		if p_enemy.time_action <= 0 then
			--check is hatching for is not regenerate particule
			eye_generate(p_enemy.x , p_enemy.y)
			p_enemy.dell = true
			generate_particules(8,7,p_enemy.x,p_enemy.y)

		else
			p_enemy.time_action -= 0.08
			
		end

	end
end
function enemies.attack(p_enemy)
	
	if math.dist(player.character.x , player.character.y , p_enemy.x , p_enemy.y) < 30 then

		local angle = math.angle(p_enemy.x , p_enemy.y , player.character.x , player.character.y)
		
		if p_enemy.tag == "eye" then
			--if delay attack inferior or egal 0 enemies attack
			if p_enemy.delay_attack <= 0 then
				--define projectile and calculation path
				local speed = 2 
				local direction={}
				direction.x = speed * sin(angle)
				direction.y = speed * cos(angle) 
				--create entiy projectile
				local projectile = generate_actor(p_enemy.x,p_enemy.y , "projectile","projectile_enemy")
				--applique direction
				projectile.direction.x = direction.x
				projectile.direction.y = direction.x
				--define default animation and sprite	
				projectile.anim.state = ""
				projectile.sprite = { 32 , 48 }
				--add projectile entity liste projectile enemies
				add(enemies.projectiles,projectile)
				--delay attack egale 5 second
				p_enemy.delay_attack = 5
			else --if delay attack superior 0 enemies not attack
				--decreases delay attack 
				p_enemy.delay_attack -= 0.2
			end
		--todo:	make enemies	
		end
	end	
end
function enemies_check_collision (p_enemy)

	local enemies_direction = {
		left= false ,
		right = false,
		hup =false,
		down = false
		}
	--check collision for 4 direction
	p_enemy.y -= 8
	enemies_direction.hup = check_collision_map(p_enemy,0)
	p_enemy.x -= 8
	enemies_direction.left = check_collision_map(p_enemy,0)
	p_enemy.y += 8
	enemies_direction.down = check_collision_map(p_enemy,0)
	p_enemy.x += 8
	enemies_direction.right = check_collision_map(p_enemy,0)
	
	--compare results
	local is_collision_to_map = false
	is_collision_to_map = enemies_direction.hup or
	 	enemies_direction.left or
	  	enemies_direction.down or
	   	enemies_direction.right

	--if there is collision
	if is_collision_to_map then
		--reposition enemies 
		if enemies_direction.hup  and enemies_direction.down == false then

			p_enemy.y += 8
		
		elseif 	enemies_direction.hup == false and enemies_direction.down then
		
			p_enemy.y -= 8
		
		end

		if enemies_direction.left  and enemies_direction.right == false then

			p_enemy.x += 8
		
		elseif 	enemies_direction.left ==false and enemies_direction.right then
		
			p_enemy.x -= 8
		end
		
		enemies_check_collision(p_enemy)
	else
		return true
	end
end	
__gfx__
00000000000000ffff000000001111111000000000000011110000000000000000000000000000000000000000000000000000000000000000000011a99aa99a
00000000000004ffff400000015555555100000000001166661100000110110001101100011011000000099000000770000007700000000000001171a111111a
0070070000000f4444f00000011555555510000000015566665510001881001018818810100100100000919000007170000071700000000000017710a111111a
000770000009941ff149900010015555551110110001566666651000188800101888881010000010000919000009170000071700000000001017710091111119
00077000009994ffff499900001111117171014400115666666555000188010001888100010001000191900001919000017170000000000001777100aaaaaaaa
0070070000f9994ff4999f00111177fff71001410015511111155110001810000018100000101000001900000019000000170000000000000177100094444449
0000000000f9999999999f000017f5fff51001110015171ff1515171000100000001000000010000010100000101000001010000000000001411100094444449
000000000ff9999999999ff00017f5fff510014100115f7777551171000000000000000000000000000000000000000000000000000000004410010099999999
000000000ff9999999999ff000117f777f100141000115f7755511710111110001111100011111000000001100000011000000110001100000000000a999999a
00000000fff4444aaa444fff01557766671101410111115ff51157770019100000181000001c1000000001cc0000017700000177001cc10000011000a1a11a1a
00000000fff0eeeeeeee0fff011577777755114117f1555151555f710019100000181000001c1000000001c1000001710000017101cc7c10001cc100a1a11a1a
00000000fff0999999990fff15555777755551f11ff1155555511571019991000188810001c7c10000001110000011100000111001ccc71001cc7c1091a11a19
00000000ffff55555555ffff15555577555551417771051555110510019791000187810001cc71000001c1000001c1000001710001cccc1001ccc710aaaaaaaa
00000000fff00ff00ff00fff1515557555511141171005111514150019799910188878101ccccc10001c1000001c10000017100001cccc1001cccc1094499449
00000000fff0fff00fff0fff0155511551100141171505155549450019999910188888101c7ccc1001c1000001c1000001710000001cc100011cc11094444449
00000000000000000fff000011111001100101411710155115145100111111101111111011111110cc1000000c10000007100000000110000001100099999999
000000001111111111111111000000000400000000000500067f0000000000000000000000066000000000000000000014410000000000001444414400000000
00000000155555511bbbbbb10050006406411100005555060051dd00090000000009900000600600000000000000000014410000000000001111111100a9a000
00080000155555511bbbbbb100777740057d751005f77f5755f116d0000a0900009aa90000600600000777000000000014410000000000004441444400909000
008e8000155555511bbbbbb101dffd10007ff551f111111f057166d000a9a00009aaaa9000aaaa00000707000000000011110000111100001111111100a9a000
00080000155555511bbbbbb1017ff710007ff5517d1661d0057166d0090a090009a7aa900aa00aa0000777000004000014410000444100004444414400090000
00000000155555511bbbbbb101555510007d75116d6666d005f116d00000000009aa7a900aa0aaa00007000000000000144100004441000011111111000aa000
00000000155555511bbbbbb1001551000001110100dddd000051dd0000000000009aa9000aa00aa0000700000000000014410000111100004444144400090000
000000001111111111111111011110000000000000000000000f7600000000000009900000aaaa000000000000000000144100004441000011111111000aa000
0000000011111111000000000000000004000000005000000067f000441441441551000000066000000000000000000000001441000000001111111100000000
0800000018888881000000000000056406411101005555000051dd00455555411551000000600600000000000000000000001441000000004441444100000000
00080800188888810000000000777740007d7511f5f77f5605f116d045656511155100000060060000006000000a000000001441000000004441444100000000
008e8000188888810000000001dffd10007ff55171111117057166d0156565411551000000aaaa000000600000a9a00000001111000011111111111111111111
080808001888888100000000017ff710007ff5516d1661df057166d045656744155100000aa00aa000006000000a000000001441000014444444444444414441
00000000188888810000000001555510057d75100d6666d055f116d045656541155100000aa0aaa0000060000000000000001441000014441111111144414441
000000001888888100000000001551000001110000dddd000051dd0015656511155100000aa00aa0004464400000000000001441000011114441444411111111
00000000111111110000000000011110000000000000000000f76000456565441551000000aaaa00000040000000000000001441000014441111111144444444
0000000000000000000009a0040000000000006000467f0060000006000000000000000060000006000000000000001100000011000000110000000000000000
000000000000000000000a94064111000000006066741dd04600006460000006000000004600006400000000000011c100001171000011710000000000000000
000000000000000000777740007d751000555474004f116d60677606466776646667766660677606666776660001cc1000017710000177100000000000000000
000000000000000001dffd10007ff551f5f77f460057166d0079970060799706647997460077770064777746101cc100101cc100101771000000000000000000
0000000000000000017ff710007ff551711111170057166d079889700798897007988970077777700777777001ccc10001ccc100017771000000000000000000
000000000000000001555510007d75116d1661df005f116d079889700078870000799700077777700077770001cc100001cc1000017710000000000000000000
000000000000000000155100000111010d6666d000051dd000799700007997000007700000777700000770001411100014111000141110000000000000000000
0000000000000000011110000000000000dddd00000f760000077000000770000000000000077000000000004410010044100100441001000000000000000000
000000000000000000000000040000000000000000067f0000011000000000000165561001655610016556100000000000000000000000000000000000000000
000000000000000000000064a94111000000000000051dd000177100000110000655556006555560065555600000000000000000000000000000000000000000
0000000000000000007777409a7d751000555500005f116d0177c710001771001585585115855851158558510000000000000000000000005550000000000000
000000000000000001dffd10007ff551f5f77f560057166d01777c100177c710dd4114dddd4114dddd4114dd0000000000000000000000057775500000000000
0000000000000000017ff710007ff551711111170057166d0177771001777c106960066669600969696009690000000000000000000000055577500000000000
000000000000000001555510007d75116d1661df005f116d01777710017777100000096900000969000000900000000000000000005555577777550000000000
000000000000000000155100000111010d6666d000051dd000177100011771100000096900000090000000000000000000000000057777777777675000000000
0000000000000000011110000000000000dddd00000f760000011000000110000000009000000000000000000000000000000000055666677777775000000000
0000000000000000000000000400c8000000006666667f0000000000000000000000000000000000111111111111111111111111000555677777675000000000
000000000000000000000064064111c00000000660051dd000000000000000000000000000000000144444411441444444441441000000567766665000000000
000000000000000000777740007d751800555506005f116d09000550095000000000000000000000144444411441444444441441000000567665565000000000
0000000000000000c1dffd10007ff551f5f77f560057166d96900696969006960000000011111111111111111111111111111111000000556655050000000000
0000000000000000817ff71c007ff551711111170057166ddd4114dddd4114dd0000000014444441155555511551111111111551000000055550000000000000
0000000000000000c1555518007d75116d1661df005f116d15855851158558510000000014444441155555511551666666661551000000000000000000000000
00000000000000000c1111c0000111c10d6666d000051dd006555510015555600000000011111111155555511551666666661551000000000000000000000000
000000000000000001111800000c8c0000dddd00000f760001655100001556100000000015555551155555511551666666661551000000000000000000000000
000000000000000000000000040c8c000000000006667f000006d1000006d1000000000015555551155555511551666666661551000000000000000000000000
000000000000000000000064064111800000006606051dd00059d5100009d5610000000015555551175555511551666666661551000000000000000000000000
000000000000000000777740007d751c00555506005f116d00564851000648560000000015555571155555511551666666661551000000000000000000000000
000000000000000001dffd1c007ff551f5f77f560057166d00001555000015550000000015555551155555511551666666661551000000000000000000000000
0000000000000000c17ff718007ff551711111170057166d00001555000015550000000015555551155555511111111111111111000000000000000000000000
00000000000000008155551c007d75116d1661df005f116d00094856005948510000000015555551155555511441444444441441000000000000000000000000
000000000000000000111180000111010d6666d000051dd60096d5610096d5100000000014444441155555511441444444441441000000000000000000000000
0000000000000000c1111c000000c80c00dddd00000f76660009d1000009d1000000000011111111111111111111111111111111000000000000000000000000
ffffffffffffffff3333333333333333333333333333333333333333c1ccc1cccc1ccc1c11511511077777777777777777700000088888888888888888800000
ffffffffffffffff3333333333333333333333333333d11dd1dd3333cc1c1c1cccc1c1c151511511777777777777777777770000888888888888888888880000
ffffffffffffffff333333333333333333333333333d66666d66d333cccccccccccccccc15155151770000000000000000770000880000000000000000880000
ffffffffffffffff333313333333333333333333333d66666666d333ccc1ccc11ccc1ccc15115155770000000000000000770000880000000000000000880000
ffffffffffffffff331313133333333333333333333d66666666d333cccccccccccccccc11515111770000000000000000770000880000000000000000880000
ffffffffffffffff333333333333333333333333333d66666666d333ccc1cc1ccccc1cc111555115770000000000000000770000880000000000000000880000
fffffffff1f1f1f13333333333333333131313133331dddd166613331c1cc1ccc1c1cc1c15515151770000000000000000770000880000000000000000880000
ffffffff11111111333333333333333311111111333166dd111d1333c1cc1ccccc1cc1cc51515151770000000000000000770000880000000000000000880000
66666671666666719999999955555550000000003331666d111d1333ccc1ccc11ccc1ccc66666666770000000000000000770000880000000000000000880000
66666671666666719999999959999910000000003331d66d111d13331ccc1c1cc1ccc1c144444444770000000000000000770000880000000000000000880000
66666671666166719999999959999910000000003331ddd1d1dd1333cccccccccccccccc44444444770000000000000000770000880000000000000000880000
666666716616667199999999599999101111111133311dd1d1dd1333c1ccc1cccc1ccc1c44444444770000000000000000770000880000000000000000880000
6666667161666671999999995999991044414441333011d0011d0333cccccccccccccccc44444444770000000000000000770000880000000000000000880000
666666716666667199999999599999104441444133300000000003331cccc1ccc1cccc1c44444444770000000000000000770000880000000000000000880000
77777771777777719999999951111110111111113330000000000333cc1c1cc11cc1c1cc44444444770000000000000000770000880000000000000000880000
11111111111111119999999900000000444aa4443333000030003333ccc1cc1ccccc1cc144444444770000000000000000770000880000000000000000880000
00000000000000005555555555555555149aa94466cccc6633555533cc1ccc1cccc1ccc144444444770000000000000000770000880000000000000000880000
000000000000000056666665656565651199991166c66c6635bbbb53c1c1ccc11c1c1ccc44444444770000000000000000770000880000000000000000880000
0000000000000000555555556565656544455444cc6cc6cc5bb55bb5cccccccccccccccc44444444770000000000000000770000880000000000000000880000
0000000000000000566666656565656511166111c6c66c6c5b5aa5b51ccc1cccc1ccc1cc44444444777777777777777777770000888888888888888888880000
0000000000000000555555556565656544455144c6c66c6c5b5aa5b5cccccccccccccccc44444444077777777777777777700000088888888888888888800000
0000000000000000566666656565656511111111cc6cc6cc5bb55bb51cc1ccccc1cc1ccc44444444000000000000000000000000000000000000000000000000
000000000000000055555555656565654444144466c66c6635bbbb53cc1cc1c11cc1cc1c44444444000000000000000000000000000000000000000000000000
000000000000000056666665555555551111111166cccc6633555533c1cccc1ccc1cccc166666666000000000000000000000000000000000000000000000000
33333333333333333333333315cccc6666cccc6666cccc5111111111000000000000000000000000000000000000000000000000000000000000000000000000
63333333333333636333333315c66c6666c66c6666c66c5155555555000000000000000000000000000000000000000000000000000000000000000000000000
766666616666667376666660156cc6cccc6cc6cccc6cc651cc6cc6cc000000000000000000000000000000000000000000000000000000000000000000000000
67777716777777636777770315c66c6cc6c66c6cc6c66c51c6c66c6c000000000000000000000000000000000000000000000000000000000000000000000000
76666166666666737666603315c66c6cc6c66c6cc6c66c51c6c66c6c000000000000000000000000000000000000000000000000000000000000000000000000
677761777766776367776033156cc6cccc6cc6cccc6cc651cc6cc6cc000000000000000000000000000000000000000000000000000000000000000000000000
60000000000000636000003315c66c665555555566c66c5166c66c66000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333315cccc661111111166cccc5166cccc66000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000144440ffff044444188888810000000018888820000000000000000000000000
0777777000000777777000077000077000000077000777770007700007700000111104ffff401111818888182222222281888820022222222222222000000000
077777770000077777700007700007700000007700077777000770000770000044400f4444f00444881881888818818888188120021881888818812000000000
07700077770770000007700770000770000000770770000077077000077000001009941ff1499001888118888881188888811820028118888881182000000000
07700007770770000007700770000770000000770770000077077000077000000ff994ffff499ff0888118888881188888811820028118888881182000000000
07700000770770000007700777000770000000770770000077077700077000000ff9994ff4999ff0881881888818818888188120021881888818812000000000
07700000770770000007700777000770000000770770000077077700077000002222222222222222818888188188881881888820028888188188882000000000
07700000770770000007700777700770000000770770000077077770077000002444444444444442188888811888888118888820028888811888882000000000
07700000770770000007700777777770000000770770000077077777777000002444444444444442028888811888888100000000028888811888882000000000
07700000770770000007700770077770000000770770000077077007777000002444444444444442028888188188881800000000028888188188882000000000
07700000770770000007700770007770000000770770000077077000777000002222222222222222021881888818818800000000021881888818812000000000
07700007770770000007700770000770077000770770000077077000077000005555555555555555028118888881188800000000028118888881182000000000
07700077770007777770000770000770077777770007777700077000077000005444444444444445028118888881188800000000028118888881182000000000
07777777700007777770000770000770007777700007777700077000077000005444444444444445021881888818818800000000021881888818812000000000
07777770000000000000000000000000000000000000000000000000000000005444444444444445028888182222222200000000022222222222222000000000
00000000000000000000000000000000000000000000000000000000000000005555555555555555028888810000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffccccc77777788888871111788871111770000000
000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffccccc77777788888787111788871117810000000
000000770077000000000000000000000000000000000000000000000000000000000000ffffffffffffffffccccc77777788888178711788871178710000000
000077777777770000777777000777777007777777777000077777770077777700000000ffffffffffffffffccccc77777788888117871788871787110000000
000077777777770007777777007777777007777777777000777777770777777770000000ffffffffffffffffccccc77777788888111787788877871110000000
000077007700770077700077007700000000000770000000770000000770000770000000ffffffffffffffffccccc77777788888111178788878711110000000
0000770077007707770000770077000000000007700000007700000007700007700000008888888817776667ccccc77777788888111117788877111100000000
0000770077007707700000770077000000000007700000007700000007700007700000008888888817776667ccccc77777788888777777788877777700000000
0000770077007707700000770077700000000007700000007700000007700007700000008888888817776667ccccc77777788888888888888888888800000000
0000770077007707777777770077777770000007700000007777777707777777700000008888888817775557ccccc77777788888888888888888888800000000
0000770077007707777777770007777770000007700000007777777707777777000000002222222216666666ccccc77777788888777777788877777700000000
0000770077007707700000770000000770000007700000007700000007700077700000002222222215555555ccccc77777788888111787788877711100000000
000077007700770770000077000000077000000770000000770000000770000770000000222222221ffff145ccccc77777788888117871788877871100000000
000077007700770770000077007777777000000770000000777777770770000770000000222222221ffff145ccccc77777788888178711788871787100000000
000077007700770770000077007777700000000770000000077777770770000770000000541ffffffffff145ccccc77777788888787111788871178700000000
00000000000000000000000000000000000000000000000000000000000000000000000054ffffffffffff45ccccc77777788888871111788871117800000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101020000000000000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010101010100000000000000000000000000010100000000000000081000000000000101000000000000000101010000000000000000000000000000000000000000000404000000000000000000000000000004040000000000000000000000000000000000000000000000000000000000000002020000000000
__map__
1010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000000000000000000000001000000000000000000000000000000010100000000000000000000000000000001000000000000000
1010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000001000000000000000
1010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000001010000000000000000000000000000000101000000000000000
3d3f3f3f943f3f3f3f3f3f3f3f943f2d3d3f3f943f3f3f3f3f3f3f943f3f3f2d3d3f3f3f3f943f3f3f3f943f3f3f3f2d3d3f3f3f3f3f3f943f3f3f3f3f3f3f2d3d3f3f3f3f3f3f3f3f3f3f3f3f3f3f2d3d3f3f3f3f3f3f3f3f3f3f3f3f3f3f2d3d3f3f3f3f3f3f3f3f3f3f3f3f3f3f2d3d3f3f3f3f3f3f3f3f3f3f3f3f3f3f2d
3c2e2e2ea42e2e2e2e2e2e2e2ea42e2c3c2e2ea42e2e2e2e2e2e2ea42e2e2e2c3c2e2e2e2ea42e2e2e2ea42e2e2e2e2c3c2e2e2e2e2e2ea42e2e2e2e2e2e2e2c3c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2c3c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2c3c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2c3c2e2ec8c92e2e2e2e2e2e2e2e2e2e2c
3c80808080808080808080808080802c3c83838383838383838385868383832c3c82838586a6a5a5a5a5a6838383832c3c91909090909090909090909090912c3c80808080808080808080808080802c3c80808080909090909080808080802c3c8787878787b3a5a5b587878787872c3c8080d8d9808080808080808080802c
3c80808080808080808080808080802c3c83b0b183838383838395968383832c3c83829596a6a5a5a5a5a6828382832c3c90909090909090909090909090902c3c80808080808080808080808080802c3c80808080909090909080808080802c3c8787878787b3a5a5b587878787872c3c8080808080808080808080e9ea802c
3c80808080808080808080808080802c3c83838383838383838383838383832c3ca6a6a6a6a6a5a5a5a5a6a6a6a6a62c3c90909190909091909090919090902c3c80808080808080808080808080802c3c81818181909090909081818181812c3c8787878787b3a5a5b587878787872c3c80808080cdcbcbcbcbce80f9fa802c
3c80808080808080808080808080802c3c83838383838383838383838383832c3ca5a5a5a5a5a68283a6a5a5a5a5a52c3c90919090909091909090909090902c3c80808080808080808080808080802c3c90909090909090909090909090902c3cb6b6b6b6b6a5a5a5a5b6b6b6b6b62c3c80808080dacacacacacc808080802c
3c80808080808080808080808080802c3c83838383838383838383838383832c3ca5a5a5a5a582838382a5a5a5a5a52c3c90909090909090919090919090902c3c80808080808080808080808080802c3c90909090909090909090909090902c3ca5a5a5a5a5a5a5a5a5a5a5a5a5a52c3c80808080dacacacacacc808080802c
3c80808080808080808080808080802c3c83838383b28383838383838383832c3ca5a5a5a5a5a68382a6a5a5a5a5a52c3c90909090919090909090909090902c3c80808080808080808080808080802c3c90909090909090909090909090902c3ca5a5a5a5a5a5a5a5a5a5a5a5a5a52c3c80808080dddbdbdbdbde808080802c
3c80808080808080808080808080802c3c83838283838383838383838383832c3ca6a6a6a6a6a5a5a5a5a6a6a6a6a62c3c90919090909090919090909090902c3c80808080808080808080808080802c3c80808080909090909080808080802c3cb4b4b4b4b4a5a5a5a5a5b4b4b4b42c3c8080808080808080808080e9ea802c
3c80808080808080808080808080802c3c83838383838383838383838283832c3c83828383a6a5a5a5a5a6858682832c3c90909090909090909090909190902c3c80808080808080808080808080802c3c80808080909090909080808080802c3c8787878787b3a5a5a5b5878787872c3c8080808080808080808080f9fa802c
3c81818181818181818181818181812c3c84848484848484848484848484842c3c83838382a6a5a5a5a5a6959683822c3c90909090909090909090909090902c3c80808080808080808080808080802c3c80808080909090909080808080802c3c8787878787b3a5a5a5b5878787872c3c80808080808080808080808080802c
3c3e3e3e3e3e3e3e3e3e3e3e3e3e3e2c3c3e3e3e3e3e3e3e3e3e3e3e3e3e3e2c3c3e3e3e3e3e3e3e3e3e3e3e3e3e3e2c3c3e3e3e3e3e3e3e3e3e3e3e3e3e3e2c3c3e3e3e3e3e3e3e3e3e3e3e3e3e3e2c3c3e3e3e3e3e3e3e3e3e3e3e3e3e3e2c3c3e3e3e3e3e3e3e3e3e3e3e3e3e3e2c3c3e3e3e3e3e3e3e3e3e3e3e3e3e3e2c
3c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2c3c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2c3c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2c3c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2c3c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2c3c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2c3c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2c3c2e2e2e2e2e2e2e2e2e2e2e2e2e2e2c
0000000000000000000000000000000000100000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
