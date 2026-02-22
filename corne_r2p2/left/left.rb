# Corne Keyboard - Left Half (Master)
#
# Holds the complete keymap for both halves.
# Receives key events from the right half (slave) via UART.

require 'keyboard'
require 'uart'

include USB::HID::Keycode
include LayerKeycode

# ==============================================================================
# Custom keycode definitions
# ==============================================================================

# USB HID keycodes not defined in R2P2
KC_LANG1 = 0x90  # かな
KC_LANG2 = 0x91  # 英数

# Shifted keycode flag (bit 8): callback strips this and adds Left Shift modifier
SHIFTED = 0x0100

S_EXLM = KC_1 | SHIFTED         # !
S_AT   = KC_2 | SHIFTED         # @
S_HASH = KC_3 | SHIFTED         # #
S_DLR  = KC_4 | SHIFTED         # $
S_PERC = KC_5 | SHIFTED         # %
S_CIRC = KC_6 | SHIFTED         # ^
S_AMPR = KC_7 | SHIFTED         # &
S_ASTER = KC_8 | SHIFTED        # *
S_LPRN = KC_9 | SHIFTED         # (
S_RPRN = KC_0 | SHIFTED         # )
S_TILD = KC_GRAVE | SHIFTED     # ~
S_PIPE = KC_BSLASH | SHIFTED    # |
S_UNDS = KC_MINUS | SHIFTED     # _
S_PLUS = KC_EQUAL | SHIFTED     # +
S_LABK = KC_COMMA | SHIFTED     # <
S_RABK = KC_DOT | SHIFTED       # >
S_LCBR = KC_LBRACKET | SHIFTED  # {
S_RCBR = KC_RBRACKET | SHIFTED  # }
S_DQUO = KC_QUOTE | SHIFTED     # "

# Composite key flag (bit 9): callback strips this and adds Right Ctrl modifier
RCTL_COMPOSITE = 0x0200
SPC_CTL = KC_SPACE | RCTL_COMPOSITE  # Space + Right Ctrl

# ==============================================================================
# Keyboard initialization
# ==============================================================================

ROW_PINS = [4, 5, 6, 7]
COL_PINS = [29, 28, 27, 26, 22, 20]

# Left side: 4 rows x 6 cols, full keymap: 4 rows x 12 cols (left + right)
kb = Keyboard.new(ROW_PINS, COL_PINS, keymap_cols: 12)
kb.tap_threshold_ms = 150

# ==============================================================================
# Layer 0: Default (QWERTY)
# ==============================================================================
kb.add_layer(:default, [
  # Left half                                                   Right half
  KC_TAB,  KC_Q,  KC_W,  KC_E,     KC_R,    KC_T,              KC_Y,          KC_U,      KC_I,     KC_O,  KC_P,      KC_MINUS,
  KC_LCTL, KC_A,  KC_S,  KC_D,     KC_F,    KC_G,              KC_H,          KC_J,      KC_K,     KC_L,  KC_SCOLON, KC_QUOTE,
  KC_LSFT, KC_Z,  KC_X,  KC_C,     KC_V,    KC_B,              KC_N,          KC_M,      KC_COMMA, KC_DOT, KC_SLASH, KC_RSFT,
  KC_NO,   KC_NO, KC_NO, KC_LANG1, KC_LGUI, LT(2, KC_SPACE),   LT(1, KC_ENTER), KC_BSPACE, KC_LANG2, KC_NO, KC_NO, KC_NO
])

# ==============================================================================
# Layer 1: Raise (symbols & navigation)
# ==============================================================================
kb.add_layer(:raise, [
  KC_GRAVE, S_EXLM, S_AT,   S_HASH,      S_DLR,   S_PERC,   S_CIRC,           S_AMPR,    S_ASTER, S_LPRN,  S_RPRN,    KC_EQUAL,
  S_TILD,   S_LABK, S_LCBR, KC_LBRACKET, S_LPRN,  KC_QUOTE, KC_LEFT,          KC_DOWN,   KC_UP,   KC_RIGHT, S_UNDS,   S_PIPE,
  KC_LSFT,  S_RABK, S_RCBR, KC_RBRACKET, S_RPRN,  S_DQUO,   S_TILD,           KC_BSLASH, KC_COMMA, KC_DOT, KC_SLASH,  KC_RSFT,
  KC_NO,    KC_NO,  KC_NO,  MT(KC_LALT, KC_2), KC_LGUI, MO(3), LT(1, KC_ENTER), SPC_CTL,  KC_NO,   KC_NO,  KC_NO,     KC_NO
])

# ==============================================================================
# Layer 2: Lower (numbers)
# ==============================================================================
kb.add_layer(:lower, [
  KC_ESC,  S_EXLM, S_AT,   S_HASH,      S_DLR,   S_PERC,            S_CIRC,   S_AMPR,  S_ASTER, S_LPRN, S_RPRN,   S_PLUS,
  KC_TAB,  KC_1,   KC_2,   KC_3,        KC_4,    KC_5,              KC_6,     KC_7,    KC_8,    KC_9,   KC_0,     KC_BSPACE,
  KC_LSFT, S_RABK, S_RCBR, KC_RBRACKET, S_RPRN,  S_DQUO,            KC_0,     KC_NO,   KC_NO,   KC_NO,  KC_SLASH, KC_COMMA,
  KC_NO,   KC_NO,  KC_NO,  MT(KC_LALT, KC_2), KC_LCTL, LT(2, KC_SPACE), MO(3), KC_RGUI, KC_NO,   KC_NO,  KC_NO,    KC_NO
])

# ==============================================================================
# Layer 3: Adjust (function keys)
# NOTE: RGB, Sounder, BOOTSEL are PRK-specific and not available in R2P2.
#       Those positions are KC_NO (transparent to lower layers).
# ==============================================================================
kb.add_layer(:adjust, [
  KC_F1, KC_F2, KC_F3, KC_F4, KC_F5,  KC_F6,  KC_F7,  KC_F8,   KC_F9, KC_F10, KC_F11, KC_F12,
  KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,  KC_NO,  KC_NO,  KC_NO,   KC_NO, KC_NO,  KC_NO,  KC_NO,
  KC_NO, KC_NO, KC_NO, KC_NO, KC_NO,  KC_NO,  KC_NO,  KC_NO,   KC_NO, KC_NO,  KC_NO,  KC_NO,
  KC_NO, KC_NO, KC_NO, KC_NO, KC_LCTL, MO(3), MO(3),  SPC_CTL, KC_NO, KC_NO,  KC_NO,  KC_NO
])

# ==============================================================================
# UART for split keyboard communication
# ==============================================================================

# Master: TX=1, RX=0 (slave uses TX=0, RX=1)
uart = UART.new(unit: 0, txd_pin: 0, rxd_pin: 1, baudrate: 115200)

SLAVE_COL_OFFSET = 6  # Right half keys map to keymap columns 6-11

# ==============================================================================
# Main loop
# ==============================================================================
kb.start do |event|
  # Read slave key events from UART
  while uart.bytes_available > 0
    data = uart.read(1)
    if data
      p "UART received: #{data.inspect}"
      byte = data.ord
      pressed = (byte & 0x80) != 0
      row = (byte >> 4) & 0x07
      col = byte & 0x0F
      kb.inject_event(row, col + SLAVE_COL_OFFSET, pressed)
    end
  end

  # Process custom keycode flags
  keycode = event[:keycode]
  modifier = event[:modifier]

  # Handle shifted keycodes: strip SHIFTED flag and add Left Shift
  if keycode & SHIFTED != 0
    keycode = keycode & 0xFF
    modifier |= 0x02  # Left Shift
  end

  # Handle composite key (SPC_CTL): strip flag and add Right Ctrl
  if keycode & RCTL_COMPOSITE != 0
    keycode = keycode & 0xFF
    modifier |= 0x10  # Right Ctrl
  end

  USB::HID.keyboard_send(modifier, keycode)
end
