-- ==============================================================================
-- Author: Cristian Vergara
-- email: <cristian.vergara@kuleuven.be>
-- Main file to define default robot and ports
-- KU Leuven 2020
-- ==============================================================================
require("context")
require("geometric")
-- robot = require("etasl_UR10")
-- robot = require("etasl_kinova_gen3")
-- robot.etasl_specification()
-- ==================== Input Ports =====================================

Fx_raw = ctx:createInputChannelScalar("Fx_raw")
Fy_raw = ctx:createInputChannelScalar("Fy_raw")
Fz_raw = ctx:createInputChannelScalar("Fz_raw")
Tx_raw = ctx:createInputChannelScalar("Tx_raw")
Ty_raw = ctx:createInputChannelScalar("Ty_raw")
Tz_raw = ctx:createInputChannelScalar("Tz_raw")

W_Fx = ctx:createInputChannelScalar("W_Fx")
W_Fy = ctx:createInputChannelScalar("W_Fy")
W_Fz = ctx:createInputChannelScalar("W_Fz")
W_Tx = ctx:createInputChannelScalar("W_Tx")
W_Ty = ctx:createInputChannelScalar("W_Ty")
W_Tz = ctx:createInputChannelScalar("W_Tz")

Fx_comp = ctx:createInputChannelScalar("Fx_comp")
Fy_comp = ctx:createInputChannelScalar("Fy_comp")
Fz_comp = ctx:createInputChannelScalar("Fz_comp")
Tx_comp = ctx:createInputChannelScalar("Tx_comp")
Ty_comp = ctx:createInputChannelScalar("Ty_comp")
Tz_comp = ctx:createInputChannelScalar("Tz_comp")

max_joint_vels ={}
min_joint_vels ={}
current_joint_vels ={}
for i=1,#robot_joints do
  max_joint_vels[i] = ctx:createInputChannelScalar("maxvel_j"..i)
  min_joint_vels[i] = ctx:createInputChannelScalar("minvel_j"..i)
  current_joint_vels[i] = ctx:createInputChannelScalar("curr_vel_j"..i)
end

-- ==================== Output ports ==================================

ctx:setOutputExpression("FT_frame",FT_frame)

ctx:setOutputExpression("Fz_desired",constant(0.0))

ctx:setOutputExpression("x_tf",constant(0))
ctx:setOutputExpression("y_tf",constant(0))
ctx:setOutputExpression("z_tf",constant(0))

ctx:setOutputExpression("roll_tf",constant(0))
ctx:setOutputExpression("pitch_tf",constant(0))
ctx:setOutputExpression("yaw_tf",constant(0))

ctx:setOutputExpression("Fx",constant(0))
ctx:setOutputExpression("Fy",constant(0))
ctx:setOutputExpression("Fz",constant(0))

ctx:setOutputExpression("Tx",constant(0))
ctx:setOutputExpression("Ty",constant(0))
ctx:setOutputExpression("Tz",constant(0))

ctx:setOutputExpression("s",constant(0))
