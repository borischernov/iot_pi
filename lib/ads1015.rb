#
# ADS1015 4-channel ADC library
# http://www.ti.com/lit/ds/symlink/ads1015-q1.pdf
#

require 'i2c/i2c'

class ADS1015
  
  REG_CONVERSION = 0;
  REG_CONFIG     = 1;
  REG_LO_THRESH  = 2;
  REG_HI_THRESH  = 3;
  
  CFG_START_CONVERSION = 0x8000     # Start single conversion
  
  CFG_MUX_DIFF01       = 0x0000     # AINP = AIN0 and AINN = AIN1
  CFG_MUX_DIFF03       = 0x1000     # AINP = AIN0 and AINN = AIN3
  CFG_MUX_DIFF13       = 0x2000     # AINP = AIN1 and AINN = AIN3
  CFG_MUX_DIFF23       = 0x3000     # AINP = AIN2 and AINN = AIN3
  CFG_MUX_AIN0         = 0x4000     # AINP = AIN0 and AINN = GND
  CFG_MUX_AIN1         = 0x5000     # AINP = AIN1 and AINN = GND
  CFG_MUX_AIN2         = 0x6000     # AINP = AIN2 and AINN = GND
  CFG_MUX_AIN3         = 0x7000     # AINP = AIN3 and AINN = GND
  CFG_MUX_MASK         = 0x7000     # MUX Mask
  
  CFG_PGA_6_144        = 0x0000     # FS = ±6.144 V
  CFG_PGA_4_096        = 0x0200     # FS = ±4.096 V
  CFG_PGA_2_048        = 0x0400     # FS = ±2.048 V
  CFG_PGA_1_024        = 0x0600     # FS = ±1.024 V
  CFG_PGA_0_512        = 0x0800     # FS = ±0.512 V
  CFG_PGA_0_256        = 0x0A00     # FS = ±0.256 V
  
  CFG_MODE_CONT        = 0x0000     # Continuous conversion mode
  CFG_MODE_SINGLE      = 0x0100     # Power-down single-shot mode (default)
  
  CFG_DR_128           = 0x0000     # 128 SPS
  CFG_DR_250           = 0x0020     # 250 SPS
  CFG_DR_490           = 0x0040     # 490 SPS
  CFG_DR_920           = 0x0060     # 920 SPS
  CFG_DR_1600          = 0x0080     # 1600 SPS
  CFG_DR_2400          = 0x00A0     # 2400 SPS
  CFG_DR_3300          = 0x00C0     # 3300 SPS
  
  CFG_COMP_TRAD        = 0x0000     # Traditional comparator
  CFG_COMP_WIND        = 0x0010     # Window comparator
  
  CFG_CMP_LOW          = 0x0000     # Comparator Active low
  CFG_CMP_HIGH         = 0x0008     # Comparator Active high
  
  CFG_CMP_NOLATCH      = 0x0000     # Non-latching comparator 
  CFG_CMP_LATCH        = 0x0004     # Latching comparator
  
  CFG_CMP_ASSERT1      = 0x0000     # Assert after 1 conversion
  CFG_CMP_ASSERT2      = 0x0001     # Assert after 2 conversions
  CFG_CMP_ASSERT4      = 0x0002     # Assert after 4 conversions
  CFG_CMP_DISABLE      = 0x0003     # Disable comparator
  
  def initialize(bus, address)
    @bus = bus
    @address = address
  end
  
  def configure(cfg_value)
    @cfg = cfg_value
    self.write_register(REG_CONFIG, cfg_value)
  end

  def read_channel(channel)
    @cfg &= ~CFG_MUX_MASK
    self.write_register(REG_CONFIG, @cfg | CFG_MUX_AIN0 | (channel << 12)) 
    self.read_register(REG_CONVERSION)
  end
  
  def write_register(reg, value)
    @bus.write(@address, reg, (value >> 8) & 0xFF, value & 0xFF)
  end
  
  def read_register(reg)
    d = @bus.read(@address, 2, reg)
    ((d[0].ord & 0xFF) << 8) + (d[1].ord & 0xFF) 
  end
  
end

