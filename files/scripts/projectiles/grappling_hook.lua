local entity_id = GetUpdatedEntityID()
local projcomp = EntityGetFirstComponentIncludingDisabled(entity_id, "ProjectileComponent")
if projcomp then
    local target = -420
    do -- Get shooter ent
        local vars = EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent") or {}
        for i = 1, #vars do
            if ComponentGetValue2(vars[i], "name") == "target_ent" then
                target = ComponentGetValue2(vars[i], "value_int")
                if target == -420 then
                    local ent_that_shot = ComponentGetValue2(projcomp, "mEntityThatShot")
                    if ent_that_shot ~= 0 then
                        target = ent_that_shot
                    else
                        target = ComponentGetValue2(projcomp, "mWhoShot")
                    end
                    ComponentSetValue2(vars[i], "value_int", target)
                end
            end
        end
    end

    if target ~= -420 and EntityGetIsAlive(target) then
        local target_x, target_y = EntityGetTransform(target)
        -- Particle logic
        local vars = EntityGetComponentIncludingDisabled(entity_id, "ParticleEmitterComponent", "disabled_at_start") or {}
        for i = 1, #vars do
            if target_x and target_y then
                ComponentSetValue2(vars[i], "mExPosition", target_x, target_y)
            end
        end
        -- Hooking logic
        local pos_x, pos_y, angle = EntityGetTransform(entity_id)
        --local targets = EntityGetInRadiusWithTag(pos_x, pos_y, 2, "hittable") or {} TODO: Stick to entities
        local found_normal, nx, ny, dist = GetSurfaceNormal(pos_x, pos_y, 2, 8)
        if found_normal then
            local angle_new = math.atan2( pos_y - target_y, pos_x - target_x );
            angle = (angle + angle_new)/2
            EntitySetTransform(entity_id, pos_x + nx * dist, pos_y + ny * dist, angle)

            -- Attractor logic
            local vcomp = EntityGetFirstComponent(target, "VelocityComponent")
            local cdc = EntityGetFirstComponent(target, "CharacterDataComponent")
            if cdc then
                local vel_x, vel_y = ComponentGetValueVector2(cdc, "mVelocity")

                local offset = {
                    x = pos_x - target_x,
                    y = pos_y - target_y
                }

                local len = math.sqrt(math.sqrt((offset.x ^ 2) + (offset.y ^ 2)))
                vel_x = vel_x + (offset.x)
                vel_y = vel_y + (offset.y)

                ComponentSetValue2(cdc, "mVelocity", vel_x, vel_y)
            elseif vcomp then
                local vel_x, vel_y = ComponentGetValueVector2(vcomp, "mVelocity")

                local offset = {
                    x = pos_x - target_x,
                    y = pos_y - target_y
                }

                local len = math.sqrt(math.sqrt((offset.x ^ 2) + (offset.y ^ 2)))
                vel_x = vel_x + (offset.x / len)
                vel_y = vel_y + (offset.y / len)

                ComponentSetValue2(vcomp, "mVelocity", vel_x, vel_y)
            end
        end
    end
end