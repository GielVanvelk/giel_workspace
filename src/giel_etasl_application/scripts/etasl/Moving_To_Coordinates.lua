--==============================================================================
-- Author: Cristian Vergara -> Gianni
-- email: <cristian.vergara@kuleuven.be>
-- Main file to move linearly along a frame axis with trapezoidal velocity
-- profile
-- KU Leuven 2020
-- ==============================================================================

require("context")
require("geometric")
utils_ts = require("utils_ts")

-- ========================================= PARAMETERS ===================================
maxvel    = ctx:createInputChannelScalar("maxvel")
maxacc    = ctx:createInputChannelScalar("maxacc")
eqradius  = ctx:createInputChannelScalar("eq_r")
endpose   = ctx:createInputChannelFrame("endpose")

fx_limits = ctx:createInputChannelScalar("force_x_limits")
fy_limits = ctx:createInputChannelScalar("force_y_limits")
fz_limits = ctx:createInputChannelScalar("force_z_limits")
tx_limits = ctx:createInputChannelScalar("torque_x_limits")
ty_limits = ctx:createInputChannelScalar("torque_y_limits")
tz_limits = ctx:createInputChannelScalar("torque_z_limits")

Fx = ctx:createInputChannelScalar("Fx_comp")
Fy = ctx:createInputChannelScalar("Fy_comp")
Fz = ctx:createInputChannelScalar("Fz_comp")
Tx = ctx:createInputChannelScalar("Tx_comp")
Ty = ctx:createInputChannelScalar("Ty_comp")
Tz = ctx:createInputChannelScalar("Tz_comp")

-- ======================================== FRAMES ========================================

tf = task_frame

-- =============================== INITIAL POSE ==============================

startpose = initial_value(time, tf)
startpos  = origin(startpose)
startrot  = rotation(startpose)

-- =============================== END POSE ==============================

endpos    = origin(endpose)
endrot    = rotation(endpose)

-- =========================== VELOCITY PROFILE ============================================

-- compute distances for displacements and rotations:
diff                    = cached(endpos-startpos)
diff, distance          = utils_ts.normalize( diff )



diff_rot                = cached(  getRotVec( inv(startrot)*endrot )) -- eq. axis of rotation for rotation from start to end:w
diff_rot, angle         = utils_ts.normalize( diff_rot )

-- plan trapezoidal motion profile in function of time:
mp = create_motionprofile_trapezoidal()
mp:setProgress(time)
mp:addOutput(constant(0), distance, maxvel, maxacc)
mp:addOutput(constant(0), angle*eqradius, maxvel, maxacc)
d  = get_output_profile(mp,0)            -- progression in distance
r  = get_output_profile(mp,1)/eqradius   -- progression in distance_rot (i.e. rot*eqradius)


-- =========================== TARGET POSE ============================================

targetpos = startpos + diff*d
targetrot = startrot*rotVec(diff_rot,r)

target    = frame(targetrot,targetpos)

-- ========================== CONSTRAINT SPECIFICATION =================================
Constraint{
    context = ctx,
    name    = "follow_path",
    expr    = inv(target)*tf,
    K       = 3,
    weight  = 1,
    priority= 2
}

-- =========================== MONITOR ============================================
Monitor{
    context=ctx,
    name='finish_after_motion',
    upper=0.0,
    actionname='exit',
    expr=time-get_duration(mp) - constant(0.1)
}

Monitor{
    context=ctx,
    name='max_fx_exceeded',
    upper= 0,
    expr= (abs(Fx) - fx_limits),
	actionname='event',
	argument = "e_force_too_high"
}

Monitor{
    context=ctx,
    name='max_fy_exceeded',
    upper= 0,
    expr= (abs(Fy) - fy_limits),
	actionname='portevent',
	argument = "e_force_too_high"
}

Monitor{
    context=ctx,
    name='max_fz_exceeded',
    upper= 0,
    expr= (abs(Fz) - fz_limits),
	actionname='portevent',
	argument = "e_force_too_high"
}

Monitor{
    context=ctx,
    name='max_tx_exceeded',
    upper= 0,
    expr= (abs(Tx) - tx_limits),
	actionname='portevent',
	argument = "e_torque_too_high"
}

Monitor{
    context=ctx,
    name='max_ty_exceeded',
    upper= 0,
    expr= (abs(Ty) - ty_limits),
	actionname='portevent',
	argument = "e_torque_too_high"
}

Monitor{
    context=ctx,
    name='max_tz_exceeded',
    upper= 0,
    expr= (abs(Tz) - tz_limits),
	actionname='portevent',
	argument = "e_torque_too_high"
}

-- ============================== OUTPUT THROUGH PORTS===================================
ctx:setOutputExpression("x_tf",coord_x(origin(tf)))
ctx:setOutputExpression("y_tf",coord_y(origin(tf)))
ctx:setOutputExpression("z_tf",coord_z(origin(tf)))

roll_tf,pitch_tf,yaw_tf = getRPY(rotation(tf))
ctx:setOutputExpression("roll_tf",roll_tf)
ctx:setOutputExpression("pitch_tf",pitch_tf)
ctx:setOutputExpression("yaw_tf",yaw_tf)
