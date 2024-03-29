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
>
```
