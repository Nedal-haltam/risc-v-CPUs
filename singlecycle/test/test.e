
#define LED (16384 - 8)
#define alu_in1   (16384 - (2 * 8))
#define alu_in2   (16384 - (3 * 8))
#define alu_out   (16384 - (4 * 8))
#define alu_start (16384 - (5 * 8))
#define alu_done  (16384 - (6 * 8))

func mmread(auto address)
{
    return *address;
}
func mmwrite(auto address, auto value)
{
    *address = value;
}

func leds_counter_loop()
{
    auto counter = 0;
    while(1)
    {
        print("counter = %d\n", counter);

        print("LEDs state: ");
        auto value = mmread(LED);
        for (auto i = 9; 0 < i; i -= 1)
        {
            if (value & (1 << i)) print("1 ");
            else                  print("0 ");
        }
        if (value & (1 << 0)) print("1 ");
        else                  print("0 ");
        print("\n");

        counter += 1;
        mmwrite(LED, counter);
        if (counter == 200) break;
    }
}

func main()
{
    mmwrite(alu_in1, 123);
    print("wrote on alu_in1\n");

    mmwrite(alu_in2, 456);
    print("wrote on alu_in2\n");

    mmwrite(alu_start, 1);
    print("triggered alu_start\n");

    print("waiting until done\n");
    while(!mmread(alu_done));
    print("it is DONE!\n");

    print("alu_out = %d\n", mmread(alu_out));

    return 0;
}
// dotnet ../Epsilon/bin/Debug/net8.0/Epsilon.dll -o ./singlecycle/test/Generated/test -dump -sim ./singlecycle/test/test.e