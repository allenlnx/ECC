vsim -novopt work.T_top_reader

add wave -divider
add wave -divider TAG.STATE.MACHINE
add wave sim:/T_top_reader/tag/core/CU/state
add wave sim:/T_top_reader/tag/core/CU/next_ts
add wave sim:/T_top_reader/tag/core/CU/op
add wave sim:/T_top_reader/tag/core/CU/next_op
add wave sim:/T_top_reader/tag/core/CU/counter
add wave sim:/T_top_reader/tag/core/ECC_CTRL/state_ECC 
add wave sim:/T_top_reader/tag/core/ECC_CTRL/state_next 
add wave sim:/T_top_reader/tag/core/ECC_CTRL/i_done_key 

add wave -divider
add wave -divider Overall.indicator
add wave sim:/T_top_reader/reader/TX
add wave sim:/T_top_reader/reader/MOD
add wave sim:/T_top_reader/tag/core/DEC/i_Authenticate_step_cu

add wave -divider
add wave -divider TAG/RNG
add wave -divider
add wave sim:/T_top_reader/tag/core/RNG/*

add wave -divider
add wave -divider TAG/rom
add wave sim:/T_top_reader/tag/rom/*

add wave -divider
add wave -divider TAG/ECC_CTRL
add wave sim:/T_top_reader/tag/core/ECC_CTRL/*


add wave -divider
add wave -divider /T_top_reader/reader/READER/PS_SP/
add wave -divider
add wave sim:/T_top_reader/reader/READER/PS_SP/*

add wave -divider
add wave -divider /T_top_reader/reader/READER/CON/
add wave -divider
add wave sim:/T_top_reader/reader/READER/CON/*


add wave -divider
add wave -divider TAG/ECC_CORE
add wave sim:/T_top_reader/tag/core/ECC/*


add wave -divider
add wave -divider Check.the.encryption.status
add wave sim:/T_top_reader/tag/core/ECC_CTRL/i_done_ECC
add wave sim:/T_top_reader/reader/READER/CON/T1_violate


add wave -divider
add wave -divider TAG/CON
add wave sim:/T_top_reader/tag/core/CU/*


add wave -divider
add wave -divider TAG/DEC
add wave sim:/T_top_reader/tag/core/DEC/*

add wave -divider
add wave -divider TAG/DEC
add wave sim:/T_top_reader/tag/core/DEM/*


add wave -divider
add wave -divider STATE:/T_top_reader/reader/READER/PS_SP/
add wave -divider
add wave sim:/T_top_reader/reader/READER/PS_SP/state
add wave sim:/T_top_reader/reader/READER/PS_SP/pre_state
add wave sim:/T_top_reader/reader/READER/PS_SP/send_state


add wave -divider
add wave -divider STATE:/T_top_reader/reader/
add wave -divider
add wave sim:/T_top_reader/reader/*

add wave -divider
add wave -divider /T_top_reader/reader/READER/PS_SP/
add wave -divider
add wave sim:/T_top_reader/reader/READER/PS_SP/*

add wave -divider
add wave -divider /T_top_reader/reader/READER/
add wave -divider
add wave sim:/T_top_reader/reader/READER/*

add wave -divider
add wave -divider TAG/ROM
add wave sim:/T_top_reader/tag/core/romInterface/*


add wave -divider 
add wave -divider STATE:/T_top_reader/reader/READER/CON/
add wave sim:/T_top_reader/reader/READER/CON/state
add wave sim:/T_top_reader/reader/READER/CON/nextstate
add wave sim:/T_top_reader/reader/READER/CON/op
add wave sim:/T_top_reader/reader/READER/CON/next_op
add wave sim:/T_top_reader/reader/READER/PS_SP/challenge_eof

add wave -divider
add wave -divider TAG/ECC_CORE
add wave sim:/T_top_reader/tag/core/OCU/*

add wave -divider
add wave -divider END
add wave -divider

run -all