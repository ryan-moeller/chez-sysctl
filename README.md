Usage
=====

```scheme
> (include "sysctl.ss")
> (sysctl-set (sysctl-name->mib "vfs.zfs.blake3_impl") "generic")
> (sysctl-get (sysctl-name->mib "vfs.zfs.blake3_impl"))
"cycle fastest [generic] sse2 sse41 avx2 "
> (sysctl-set (sysctl-name->mib "vfs.zfs.blake3_impl") "fastest")
> (sysctl-get (sysctl-name->mib "vfs.zfs.blake2_impl"))
"cycle [fastest] generic sse2 sse41 avx2 "
>
```
