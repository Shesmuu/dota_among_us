Quest = class( {} )

picture = 1

function Quest:constructor( player, name, data, units, customSettings )
	self.player = player
	self.name = name
	self.taskPoints = data.taskPoints or 1
	self.type = data.type
	self.minigame = {
		type = self.type,
		result = function( data )
			if data.completed == 1 then
				self:MinigameCompleted()
			elseif data.failure == 1 then
				self.player:SetMinigame()
			end
		end
	}

	if not customSettings then
		local targets = {}
		local l = #units

		for i = 1, l do
			targets[i] = i
		end

		for i = 1, l do
			local r = RandomInt( 1, l )

			targets[i], targets[r] = targets[r], targets[i]
		end

		for i, target in pairs( targets ) do
			targets[i] = units[target]
		end

		if data.stepCount then
			self.stepCount = data.stepCount
			self.stepNow = 1
			self.targets = targets
		else
			self.target = targets[1]
		end
	end


	self.index = Add( player.quests, self )

	self:Effect()
end

function Quest:Trigger( unit )
	if self:GetTargetUnit() == unit then
		self.player:SetMinigame( self.minigame )
	end
end

function Quest:Effect()
	local target = self:GetTargetUnit()

	if target then
		self.effect = ParticleManager:CreateParticleForTeam(
			"particles/msg_fx/msg_deniable.vpcf",
			PATTACH_ABSORIGIN,
			self.player.hero,
			self.player.team
		)
		ParticleManager:SetParticleControl( self.effect, 0, target:GetAbsOrigin() + Vector( 0, 0, -120 ) )
	end
end

function Quest:DestroyEffect()
	if self.effect then
		ParticleManager:DestroyParticle( self.effect, false )
	end
end

function Quest:MinigameCompleted()
	if self.completed then
		return
	end

	if self.stepCount then
		self.stepNow = self.stepNow + 1

		self:DestroyEffect()

		if self.stepCount < self.stepNow then
			self:Complete()
		else
			self:Effect()
		end

	else
		self:Complete()
	end

	self.player:SetMinigame()
end

function Quest:Complete()
	if self.completed then
		return
	end

	if self.stepCount then
		self.stepNow = self.stepCount + 1
	end

	self.completed = true

	if self.OnComplete then
		self:OnComplete()
	end

	self:DestroyEffect()

	Quests:AddTaskPoints( self.taskPoints )
end

function Quest:GetTargetUnit()
	if self.completed then
		return
	end
	if self.stepCount then
		return self.targets[self.stepNow]
	elseif not self.completed then
		return self.target
	end
end

function Quest:Destroy()
	self:DestroyEffect()

	if self.OnDestroy then
		self:OnDestroy()
	end

	self.player.quests[self.index] = nil
end

function Quest:GetNetTableData()
	local target = self:GetTargetUnit()

	return {
		name = self.name,
		step_count = self.stepCount,
		progress = self.stepNow and self.stepNow - 1 or nil,
		completed = self.completed,
		target = target and target:GetEntityIndex() or nil
	}
end