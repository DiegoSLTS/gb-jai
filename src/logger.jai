#import "Basic";

logger :: inline (address: u16) {
    print("%: ", u16ToHex(address));
}

logger :: inline (args: string, info: string) {
    if args.count > 0
        print(args);

    if info.count > 0
        print(" ; %", info);

    print("\n");
}

logger :: inline (arg: FormatInt, info: string) {
    print("%",arg);

    if info.count > 0
        print(" ; %", info);

    print("\n");
}

logger :: inline (message: string) {
    print(message);
}

u8ToHex :: #bake_arguments formatInt(base=16, minimum_digits=2);  /*OLD inline (arg: *u8) -> FormatInt {
    return formatInt(<< arg, base=16, minimum_digits=2);
}*/

u16ToHex :: #bake_arguments formatInt(base=16, minimum_digits=4); /*OLD inline (arg: *u16) -> FormatInt {
    return formatInt(<< arg, base=16, minimum_digits=4);
}*/

u32ToHex :: #bake_arguments formatInt(base=16, minimum_digits=8);