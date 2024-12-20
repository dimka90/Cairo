

fn main() {

let mut number: Array = ArrayTrait::<felt252>::new();

number.append(9000);
// let _number2 = Box::new(5);
match number.get(0){
Option::Some(_value) => println!(" i am doing great"),
Option::None => println!("ccc"),
};

let _num:Array = addToArray(34);
println!("{}", _num.at(0));
match _num.get(0) {
Option::Some(value) => println!("Value exit"),
Option::None => println!("None"),
}
println!("{}", _num.at(0))
}

fn addToArray(x:u32) -> Array<u32> {
 let mut _arr = ArrayTrait::<u32>::new();

_arr.append(x);

return  _arr;
}


