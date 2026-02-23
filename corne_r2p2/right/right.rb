# Corne Keyboard - Right Half (Slave)
#
# Scans the local key matrix and sends raw events to the master (left)
# via UART. No keymap processing happens on this side.

require 'keyboard_matrix'
require 'uart'

# Pin configuration (Corne RP2040)
ROW_PINS = [4, 5, 6, 7]
COL_PINS = [29, 28, 27, 26, 22, 20]

# Initialize keyboard matrix
matrix = KeyboardMatrix.new(ROW_PINS, COL_PINS)
matrix.debounce_ms = 5

# Initialize UART for communication with master
# TX=pin0, RX=pin1 (UART0 on RP2040)
uart = UART.new(unit: :RP2040_UART0, txd_pin: 0, rxd_pin: 1, baudrate: 115200)

# Protocol: 1-byte encoding
# Bit 7: pressed (1) / released (0)
# Bits 4-6: row (0-7)
# Bits 0-3: col (0-15)
loop do
  if event = matrix.scan
    byte = 0
    byte |= 0x80 if event[:pressed]
    byte |= (event[:row] & 0x07) << 4
    byte |= event[:col] & 0x0F
    p "TX: byte=#{byte} row=#{event[:row]} col=#{event[:col]} pressed=#{event[:pressed]}"
    uart.write(byte.chr)
  end
  sleep_ms(1)
end
