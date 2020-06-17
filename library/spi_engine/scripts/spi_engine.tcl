proc spi_engine_bd {{name "hier_spi_engine"} {data_width 32} {async_spi_clk 1} {num_cs 1} {num_sdi 1} {sdi_delay 2}} {

  create_bd_cell -type hier $name
  current_bd_instance /$name

  create_bd_pin -dir I -type clk spi_clk
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -type rst resetn
  create_bd_pin -dir O irq
  create_bd_intf_pin -mode Master -vlnv analog.com:interface:spi_master_rtl:1.0 m_spi
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_SAMPLE
  
  ad_ip_instance spi_engine_execution execution
  ad_ip_parameter execution CONFIG.DATA_WIDTH $data_width
  ad_ip_parameter execution CONFIG.NUM_OF_CS $num_cs
  ad_ip_parameter execution CONFIG.NUM_OF_SDI $num_sdi
  ad_ip_parameter execution CONFIG.SDO_DEFAULT 1
  ad_ip_parameter execution CONFIG.SDI_DELAY $sdi_delay

  ad_ip_instance axi_spi_engine axi_regmap
  ad_ip_parameter axi_regmap CONFIG.DATA_WIDTH $data_width
  ad_ip_parameter axi_regmap CONFIG.NUM_OFFLOAD 1
  ad_ip_parameter axi_regmap CONFIG.ASYNC_SPI_CLK $async_spi_clk

  ad_ip_instance spi_engine_offload offload
  ad_ip_parameter offload CONFIG.DATA_WIDTH $data_width
  ad_ip_parameter offload CONFIG.ASYNC_SPI_CLK $async_spi_clk

  ad_ip_instance spi_engine_interconnect interconnect
  ad_ip_parameter interconnect CONFIG.DATA_WIDTH $data_width

  ad_connect axi_regmap/spi_engine_offload_ctrl0 offload/spi_engine_offload_ctrl
  ad_connect offload/spi_engine_ctrl interconnect/s0_ctrl
  ad_connect axi_regmap/spi_engine_ctrl interconnect/s1_ctrl
  ad_connect interconnect/m_ctrl execution/ctrl
  ad_connect offload/offload_sdi M_AXIS_SAMPLE

  ad_connect execution/spi m_spi

  ad_connect spi_clk offload/spi_clk
  ad_connect spi_clk offload/ctrl_clk
  ad_connect spi_clk execution/clk
  ad_connect clk axi_regmap/s_axi_aclk
  ad_connect spi_clk axi_regmap/spi_clk
  ad_connect spi_clk interconnect/clk

  ad_connect axi_regmap/spi_resetn offload/spi_resetn
  ad_connect axi_regmap/spi_resetn execution/resetn
  ad_connect axi_regmap/spi_resetn interconnect/resetn

  ad_connect resetn axi_regmap/s_axi_aresetn
  ad_connect irq axi_regmap/irq
  
  current_bd_instance /
}
