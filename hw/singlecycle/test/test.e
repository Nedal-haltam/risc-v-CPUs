
#define LED (16384 - (1 * 8))

#define alu_in1   (16384 - (2 * 8))
#define alu_in2   (16384 - (3 * 8))
#define alu_out   (16384 - (4 * 8))
#define alu_start (16384 - (5 * 8))
#define alu_done  (16384 - (6 * 8))

#define vadd_addr_in1 (16384 - (7 * 8))
#define vadd_addr_in2 (16384 - (8 * 8))
#define vadd_addr_out (16384 - (9 * 8))
#define vadd_vsize    (16384 - (10 * 8))
#define vadd_start    (16384 - (11 * 8))
#define vadd_done     (16384 - (12 * 8))

#define conv1d_addr_in1 (16384 - (13 * 8))
#define conv1d_addr_in2 (16384 - (14 * 8))
#define conv1d_addr_out (16384 - (15 * 8))
#define conv1d_vsize    (16384 - (16 * 8))
#define conv1d_start    (16384 - (17 * 8))
#define conv1d_done     (16384 - (18 * 8))

#define conv1d_pl_addr_in1 (16384 - (19 * 8))
#define conv1d_pl_addr_in2 (16384 - (20 * 8))
#define conv1d_pl_addr_out (16384 - (21 * 8))
#define conv1d_pl_vsize    (16384 - (22 * 8))
#define conv1d_pl_start    (16384 - (23 * 8))
#define conv1d_pl_done     (16384 - (24 * 8))

func mmread(auto address)
{
    return *address;
}
func mmwrite(auto address, auto value)
{
    *address = value;
}

func mm_leds_counter_loop()
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

func mm_alu_add()
{
    print("--------------MM ALU example started--------------\n");
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
    print("--------------------------------------------------\n");
}
#define VADD_VSIZE 10
func mm_vadd()
{
    print("---------------------MM vector add example started---------------------\n");
    auto xs[VADD_VSIZE];
    auto ys[VADD_VSIZE];
    auto zs[VADD_VSIZE];

    for (auto i = 0; i < VADD_VSIZE; i += 1) xs[i] = 3 * (i + 1) + 1;
    for (auto i = 0; i < VADD_VSIZE; i += 1) ys[i] = 4 * (i + 1) + 1;
    for (auto i = 0; i < VADD_VSIZE; i += 1) zs[i] = 0;

    mmwrite(vadd_addr_in1, xs);
    mmwrite(vadd_addr_in2, ys);
    mmwrite(vadd_addr_out, zs);
    mmwrite(vadd_vsize, VADD_VSIZE);

    print("xs mmread(%d), (%d): ", mmread(vadd_addr_in1), xs); for (auto i = 0; i < VADD_VSIZE; i += 1) print("%d ", xs[i]); print("\n");
    print("ys mmread(%d), (%d): ", mmread(vadd_addr_in2), ys); for (auto i = 0; i < VADD_VSIZE; i += 1) print("%d ", ys[i]); print("\n");
    print("zs mmread(%d), (%d): ", mmread(vadd_addr_out), zs); for (auto i = 0; i < VADD_VSIZE; i += 1) print("%d ", zs[i]); print("\n");

    mmwrite(vadd_start, 1);
    while(!mmread(vadd_done));

    print("it is DONE!\n");

    print("xs mmread(%d), (%d): ", mmread(vadd_addr_in1), xs); for (auto i = 0; i < VADD_VSIZE; i += 1) print("%d ", xs[i]); print("\n");
    print("ys mmread(%d), (%d): ", mmread(vadd_addr_in2), ys); for (auto i = 0; i < VADD_VSIZE; i += 1) print("%d ", ys[i]); print("\n");
    print("zs mmread(%d), (%d): ", mmread(vadd_addr_out), zs); for (auto i = 0; i < VADD_VSIZE; i += 1) print("%d ", zs[i]); print("\n");

    print("-----------------------------------------------------------------------\n");
}

#define CONV1D_VSIZE 4
func mm_conv1d()
{
    print("---------------------MM 1D convolution example started---\n");
    auto xs[CONV1D_VSIZE];
    auto ys[CONV1D_VSIZE];
    auto zs[2 * CONV1D_VSIZE - 1];
    for (auto i = 0; i < CONV1D_VSIZE; i += 1) xs[i] = 2 * (i + 1) + 1;
    for (auto i = 0; i < CONV1D_VSIZE; i += 1) ys[i] = 3 * (i + 1) + 1;
    for (auto i = 0; i < 2 * CONV1D_VSIZE - 1; i += 1) zs[i] = 0;
    for (auto i = 0; i < CONV1D_VSIZE; i += 1)
    {
        for (auto j = 0; j < CONV1D_VSIZE; j += 1)
        {
            zs[i + j] += xs[i] * ys[j];
        }
    }
    print("Golden output:\n");
    print("xs: "); for (auto i = 0; i < CONV1D_VSIZE; i += 1) print("%d ", xs[i]); print("\n");
    print("ys: "); for (auto i = 0; i < CONV1D_VSIZE; i += 1) print("%d ", ys[i]); print("\n");
    print("zs: "); for (auto i = 0; i < 2 * CONV1D_VSIZE - 1; i += 1) print("%d ", zs[i]); print("\n");
    for (auto i = 0; i < 2 * CONV1D_VSIZE - 1; i += 1) zs[i] = 0;

    mmwrite(conv1d_addr_in1, xs);
    mmwrite(conv1d_addr_in2, ys);
    mmwrite(conv1d_addr_out, zs);
    mmwrite(conv1d_vsize, CONV1D_VSIZE);

    print("Before:\n");
    print("xs: "); for (auto i = 0; i < CONV1D_VSIZE; i += 1) print("%d ", xs[i]); print("\n");
    print("ys: "); for (auto i = 0; i < CONV1D_VSIZE; i += 1) print("%d ", ys[i]); print("\n");
    print("zs: "); for (auto i = 0; i < 2 * CONV1D_VSIZE - 1; i += 1) print("%d ", zs[i]); print("\n");

    mmwrite(conv1d_start, 1);
    while(!mmread(conv1d_done));

    print("it is DONE!\n");

    print("Accelerator Output:\n");
    print("xs: "); for (auto i = 0; i < CONV1D_VSIZE; i += 1) print("%d ", xs[i]); print("\n");
    print("ys: "); for (auto i = 0; i < CONV1D_VSIZE; i += 1) print("%d ", ys[i]); print("\n");
    print("zs: "); for (auto i = 0; i < 2 * CONV1D_VSIZE - 1; i += 1) print("%d ", zs[i]); print("\n");
    print("---------------------------------------------------------------\n");
}

#define CONV1D_PL_VSIZE 4
func mm_conv1d_pl()
{
    print("-------MM 1D convolution (PL) example started---\n");
    auto xs[CONV1D_PL_VSIZE];
    auto ys[CONV1D_PL_VSIZE];
    auto zs[2 * CONV1D_PL_VSIZE - 1];
    for (auto i = 0; i < CONV1D_PL_VSIZE; i += 1) xs[i] = 2 * (i + 1) + 1;
    for (auto i = 0; i < CONV1D_PL_VSIZE; i += 1) ys[i] = 3 * (i + 1) + 1;
    for (auto i = 0; i < 2 * CONV1D_PL_VSIZE - 1; i += 1) zs[i] = 0;
    for (auto i = 0; i < CONV1D_PL_VSIZE; i += 1)
    {
        for (auto j = 0; j < CONV1D_PL_VSIZE; j += 1)
        {
            zs[i + j] += xs[i] * ys[j];
        }
    }
    print("Golden output:\n");
    print("xs: "); for (auto i = 0; i < CONV1D_PL_VSIZE; i += 1) print("%d ", xs[i]); print("\n");
    print("ys: "); for (auto i = 0; i < CONV1D_PL_VSIZE; i += 1) print("%d ", ys[i]); print("\n");
    print("zs: "); for (auto i = 0; i < 2 * CONV1D_PL_VSIZE - 1; i += 1) print("%d ", zs[i]); print("\n");
    for (auto i = 0; i < 2 * CONV1D_PL_VSIZE - 1; i += 1) zs[i] = 0;

    mmwrite(conv1d_pl_addr_in1, xs);
    mmwrite(conv1d_pl_addr_in2, ys);
    mmwrite(conv1d_pl_addr_out, zs);
    mmwrite(conv1d_pl_vsize, CONV1D_PL_VSIZE);

    print("Before:\n");
    print("xs: "); for (auto i = 0; i < CONV1D_PL_VSIZE; i += 1) print("%d ", xs[i]); print("\n");
    print("ys: "); for (auto i = 0; i < CONV1D_PL_VSIZE; i += 1) print("%d ", ys[i]); print("\n");
    print("zs: "); for (auto i = 0; i < 2 * CONV1D_PL_VSIZE - 1; i += 1) print("%d ", zs[i]); print("\n");

    mmwrite(conv1d_pl_start, 1);
    while(!mmread(conv1d_pl_done));

    print("it is DONE!\n");

    print("Accelerator Output:\n");
    print("xs: "); for (auto i = 0; i < CONV1D_PL_VSIZE; i += 1) print("%d ", xs[i]); print("\n");
    print("ys: "); for (auto i = 0; i < CONV1D_PL_VSIZE; i += 1) print("%d ", ys[i]); print("\n");
    print("zs: "); for (auto i = 0; i < 2 * CONV1D_PL_VSIZE - 1; i += 1) print("%d ", zs[i]); print("\n");
    print("---------------------------------------------------------------\n");
}

func main()
{
    mm_leds_counter_loop();
    return 0;
}
// dotnet ../Epsilon/bin/Debug/net8.0/Epsilon.dll -o ./singlecycle/test/Generated/test -dump -sim ./singlecycle/test/test.e
