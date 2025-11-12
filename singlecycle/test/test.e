
func main()
{
    auto led = 16384 - 8;
    auto counter = 0;
    while(1)
    {
        print("counter = %d\n", counter);

        print("LEDs state: ");
        auto value = *led;
        for (auto i = 9; 0 < i; i -= 1)
        {
            if (value & (1 << i)) print("1 ");
            else                  print("0 ");
        }
        if (value & (1 << 0)) print("1 ");
        else                  print("0 ");
        print("\n");

        counter += 1;
        *led = counter;
        if (counter == 200) break;
    }

    return 0;
}
