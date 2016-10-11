
--	had some music, need to revise 

module(..., package.seeall)

--local bgMusic = audio.loadStream("bgMusic.mp3")
local editMusic = audio.loadStream("TestOne_2.wav")
function bgChannel()
	audio.play(bgMusic,{channel=1,loops=-1})

end

function editChannelPlay()
	audio.play(editMusic,{channel=1,loops=-1})
end

function editChannelEnd()
	audio.stop(editMusic)
	editMusic = nil
	audio.dispose(editMusic)
end
