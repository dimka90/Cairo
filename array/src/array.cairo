#[derive(Copy, Drop)]
enum Data{
interger: u128,
name: felt252,
}

fn main()
{
let mut a = ArrayTrait::<u128>::new();
a.append(0);
a.append(90);

let _first = assert(*a[0] == 0 , 'Item must be zero');
println!("{}",a.len());

let arrays = array![1,3,4,4,5,6];
println!("{}", arrays[3]);

let mut  name:Array<Data>  = ArrayTrait::new();
name.append(Data::interger(9));

}
