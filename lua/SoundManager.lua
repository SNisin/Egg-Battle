local SoundManager = {}
local this = {}
function SoundManager.load(mute)
	this.music = {
		menu = love.audio.newSource( "sfx/Sunny-Fields-Gallop.ogg", "stream" ),
		game = love.audio.newSource( "sfx/Monkeys-Spinning-Monkeys.ogg", "stream" )
	}
	this.sounds = {
		hit = love.audio.newSource( "sfx/Hit.ogg", "static" ),
		win = love.audio.newSource( "sfx/win.ogg", "static" ),
		lost = love.audio.newSource( "sfx/lost.ogg", "static" )
	}
	this.mute = mute or false
	this.oldMusic = ""
	this.playingMusic = ""

	this.curfade = ""
	this.fade = 1
	this.fadeDuration = 1
end
function SoundManager.update(dt)
	if not this.music then
		return
	end
	if this.curfade == "up" and this.fade<1 then
		this.fade = this.fade + dt * (1/this.fadeDuration)

		this.fade = math.min(this.fade, 1)

		if this.music[this.playingMusic] then
			this.music[this.playingMusic]:setVolume(this.fade)
		end

	elseif this.curfade == "down" and this.fade>0 then
		this.fade = this.fade - dt * (1/this.fadeDuration)
		
		if this.fade <= 0 then
			if this.music[this.oldMusic] then
				this.music[this.oldMusic]:stop()
			end
			this.fade = 0
			this.curfade = "up"
		end

		if this.music[this.oldMusic] then
			this.music[this.oldMusic]:setVolume(this.fade)
		end
	end
end
function SoundManager.setMute(mute)
	if not this.music then
		return
	end
	this.mute = mute
	if mute then
		if this.music[this.playingMusic] then
			this.music[this.playingMusic]:pause()
		end
	else
		if this.music[this.playingMusic] then
			this.music[this.playingMusic]:play()
		end
	end
end
function SoundManager.isMute()
	if not this.music then
		return
	end
	return this.mute
end
function SoundManager.playMusic(music, fade)
	if this.playingMusic == music or not this.music then
		return
	end
	fade = not fade
	if this.music[music] then
		this.oldMusic = this.playingMusic
		
		this.playingMusic = music
		if fade then
			this.music[music]:setVolume(0)
		else
			this.music[music]:setVolume(1)
			if this.music[this.oldMusic] then
				this.music[this.oldMusic]:stop()
			end
		end
		if not this.mute then
			this.music[music]:play()
		end
	end
	if fade then
		this.curfade = "down"
		this.fade = 1
	end
end
function SoundManager.playSound(sound, rewind)
	if not this.music then
		return
	end
	if this.sounds[sound] and not this.mute then
		if rewind then
			this.sounds[sound]:rewind()
		end
		this.sounds[sound]:play()
	end
end
	
return SoundManager