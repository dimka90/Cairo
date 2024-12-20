fn main() {
    add(4,6);
}

fn add(a:u128, b:u128) ->u128
{

a + b
}

#[cfg(test)]
mod tests {
    use super::add;

    #[test]
    fn it_works() {
        assert(add(10,10) == 20, 'it works!');
    }
    #[test]
    fn it_fails()
{
assert(add(10,13) != 22, 'It fails');
}
}
