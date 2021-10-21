use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
pub enum Sex {
    F,
    M,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Name {
    pub name: String,
    pub sex: Sex,
}
