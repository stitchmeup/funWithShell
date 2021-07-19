BEGIN {
    FS="\t"
}
{
    print   "<row>"
    print   "<entry>"$1"</entry>"
    print   "<entry>"
    print   $2
    print   "</entry>"
    print   "</row>"
}
