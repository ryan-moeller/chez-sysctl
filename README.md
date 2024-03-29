Usage
=====

```scheme
> (import (sysctl))
> (sysctl-set (sysctl-name->mib "vfs.zfs.blake3_impl") "generic")
> (sysctl-get (sysctl-name->mib "vfs.zfs.blake3_impl"))
"cycle fastest [generic] sse2 sse41 avx2 "
> (sysctl-set (sysctl-name->mib "vfs.zfs.blake3_impl") "fastest")
> (sysctl-get (sysctl-name->mib "vfs.zfs.blake3_impl"))
"cycle [fastest] generic sse2 sse41 avx2 "
> (length (sysctl-all))
17341
> (length (sysctl-all-noskip))
20904
> (sysctl-name '#(1))
"kern"
> (sysctl-get '#(1))
node
> (sysctl-get '#(1 0))
Exception occurred with non-condition value "No such file or directory"
Type (debug) to enter the debugger.
> (sysctl-description (sysctl-name->mib "dev.cpu.0.freq"))
"Current CPU frequency"
> (sysctl-format (sysctl-name->mib "dev.cpu.0.freq"))
(3254781954 . "I")
> (sysctl-get (sysctl-name->mib "dev.cpu.0.freq"))
3500
>
```
