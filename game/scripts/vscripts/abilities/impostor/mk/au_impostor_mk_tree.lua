au_impostor_mk_tree = class({})

LinkLuaModifier( "modifier_generic_arc_lua", "abilities/impostor/mk/modifier_au_impostor_mk_tree", LUA_MODIFIER_MOTION_BOTH  )
LinkLuaModifier( "modifier_au_impostor_mk_tree", "abilities/impostor/mk/modifier_au_impostor_mk_tree", LUA_MODIFIER_MOTION_BOTH  )

function au_impostor_mk_tree:GetBehavior()
    if self:GetCaster():HasModifier("modifier_au_impostor_mk_tree") then
        return DOTA_ABILITY_BEHAVIOR_POINT
    end

    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function au_impostor_mk_tree:GetCastAnimation()
	if self:GetCaster():HasModifier("modifier_au_impostor_mk_tree") then
		return ACT_DOTA_CAST_ABILITY_2
	end
	return ACT_DOTA_MK_SPRING_END
end

function au_impostor_mk_tree:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_au_impostor_mk_tree") then
		return "monkey_king_primal_spring"
	end
	return "monkey_king_tree_dance"
end

function au_impostor_mk_tree:GetCastRange(location, target)
	if self:GetCaster():HasModifier("modifier_au_impostor_mk_tree") then
		return 30000
	end
	return self:GetSpecialValueFor( "radius" )
end

function au_impostor_mk_tree:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if self:GetCaster():HasModifier("modifier_au_impostor_mk_tree") then
		local point = self:GetCursorPosition()
		local max_distance = 1000
		local direction = (point-caster:GetOrigin())
		direction.z = 0
		if direction:Length2D()>max_distance then
			point = caster:GetOrigin() + direction:Normalized() * max_distance
			point.z = GetGroundHeight( point, caster )
		end
		self:StartCooldown( self:GetSpecialValueFor( "cooldown" ))

		local speed = 1200
		local distance = (point-caster:GetOrigin()):Length2D()
		local arc_height = 500
		local perch_height = 256
		local height = 150

		local arc = caster:AddNewModifier(
			caster,
			self,
			"modifier_generic_arc_lua",
			{
				target_x = point.x,
				target_y = point.y,
				distance = distance,
				speed = speed,
				height = height,
				fix_end = false,
				activity = ACT_DOTA_MK_SPRING_SOAR,
				isStun = true,
				start_offset = perch_height,
			}
		)
		arc:SetEndCallback(function()
			caster:FindAbilityByName("au_impostor_kill"):SetActivated( true )
		end)
		return
	end

	local arc_height = 500
	local position = target:GetOrigin()
	local perch_height = 256
	local speed = 1000
	local height = 192
	local distance = (target:GetOrigin()-caster:GetOrigin()):Length2D()

	local perch = 0
	if caster:FindModifierByNameAndCaster( "modifier_au_impostor_mk_tree", caster ) then
		perch = 1
	end

	local arc = caster:AddNewModifier(
		caster,
		self,
		"modifier_generic_arc_lua",
		{
			target_x = target:GetOrigin().x,
			target_y = target:GetOrigin().y,
			distance = distance,
			speed = speed,
			height = height,
			fix_end = false,
			fix_height = false,
			isStun = true,
			activity = ACT_DOTA_MK_TREE_SOAR,
			start_offset = perch_height*perch,
			end_offset = perch_height,
		}
	)
	arc:SetEndCallback(function()
		caster:AddNewModifier(
			caster, 
			self,
			"modifier_au_impostor_mk_tree",
			{
				tree = target:entindex(),
			}
		)
		caster:FindAbilityByName("au_impostor_kill"):SetActivated( false )
	end)

	self:PlayEffects( arc )
end

function au_impostor_mk_tree:PlayEffects( modifier )
	local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_monkey_king/monkey_king_jump_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

	modifier:AddParticle(
		effect_cast,
		false,
		false, 
		-1,
		false, 
		false
	)
end