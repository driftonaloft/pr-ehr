module util.array;

long validateIndex(T)( T[] array, long index , bool matchLength = false) {
    long retval = index;
    if( retval >= array.length ) {
        retval = matchLength ? array.length : array.length - 1;
    }
    if(retval < 0 ) {
        retval = 0;
    }
    return retval;
}

unittest {
    import std.stdio;
    int [] a = [0,1,2,3,4,5,6,7];
    long i = validateIndex(a, -1);
    writeln(i);
    i = validateIndex(a, 16);
    writeln(i);
    i = validateIndex(a, 7);
    writeln(i);
    i = validateIndex(a, 3);
    writeln(i);
    i = validateIndex(a, -9);
    writeln(i);
}