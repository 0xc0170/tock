pub const WAIT: u8 = 0;
pub const SUBSCRIBE: u8 = 1;
pub const COMMAND: u8 = 2;

pub enum ReturnTo {
  Process = 0,
  Kernel = 1
}

