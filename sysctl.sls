(library (sysctl)
  (export sysctl-name->mib
	  sysctl-name
	  sysctl-format
	  sysctl-description
	  sysctl-label
	  sysctl-get
	  sysctl-set
	  sysctl-list
	  sysctl-list-noskip
	  sysctl-all
	  sysctl-all-noskip)
  (import (chezscheme))

  (define init (load-shared-object "libc.so.7"))

  (define sysctl
    (foreign-procedure "sysctl" ((* int) unsigned void* (* size_t) void* size_t) int))

  (define sysctlbyname
    (foreign-procedure "sysctlbyname" (string void* (* size_t) void* size_t) int))

  (define sysctlnametomib
    (foreign-procedure "sysctlnametomib" (string (* int) (* size_t)) int))

  (define &errno
    (foreign-entry "errno"))

  (define errno
    (lambda ()
      (foreign-ref 'int &errno 0)))

  (define strerror
    (foreign-procedure "strerror" (int) string))

  (define CTL_MAXNAME 24)

  (define CTLTYPE #xf)

  (define CTL_SYSCTL 0)
  (define CTL_SYSCTL_NAME 1)
  (define CTL_SYSCTL_NEXT 2)
  (define CTL_SYSCTL_OIDFMT 4)
  (define CTL_SYSCTL_OIDDESCR 5)
  (define CTL_SYSCTL_OIDLABEL 6)
  (define CTL_SYSCTL_NEXTNOSKIP 7)

  (define ENOENT 2)
  (define EISDIR 21)

  (define BUFSIZ 1024)

  (define sysctl-name->mib
    (lambda (name)
      (let ([mibp (make-ftype-pointer int (foreign-alloc (* (ftype-sizeof int) CTL_MAXNAME)))]
            [lenp (make-ftype-pointer size_t (foreign-alloc (ftype-sizeof size_t)))])
	(ftype-set! size_t () lenp CTL_MAXNAME)
	(if (= -1 (sysctlnametomib name mibp lenp))
            (let ([err (errno)])
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address lenp))
	      (raise (strerror err)))
	    (let* ([len (ftype-ref size_t () lenp)]
		   [mib (make-vector len)])
	      (do ([i 0 (+ i 1)])
		  ((= i len))
		(vector-set! mib i (ftype-ref int () mibp i)))
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address lenp))
	      mib)))))

  (define sysctl-next
    (lambda (mib)
      (let* ([len (vector-length mib)]
	     [miblen (+ 2 len)]
	     [buflen (* (ftype-sizeof int) CTL_MAXNAME)]
	     [mibp (make-ftype-pointer int (foreign-alloc (* (ftype-sizeof int) miblen)))]
	     [bufp (make-ftype-pointer int (foreign-alloc buflen))]
	     [lenp (make-ftype-pointer size_t (foreign-alloc (ftype-sizeof size_t)))])
	(ftype-set! size_t () lenp buflen)
	(ftype-set! int () mibp 0 CTL_SYSCTL)
	(ftype-set! int () mibp 1 CTL_SYSCTL_NEXT)
	(do ([i 0 (+ i 1)])
	    ((= i len))
	  (ftype-set! int () mibp (+ 2 i) (vector-ref mib i)))
	(if (= -1 (sysctl mibp miblen (ftype-pointer-address bufp) lenp 0 0))
	    (let ([err (errno)])
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      (if (= err ENOENT)
		  #f
		  (raise (strerror err))))
	    (let* ([len (/ (ftype-ref size_t () lenp) (ftype-sizeof int))]
		   [nxt (make-vector len)])
	      (do ([i 0 (+ i 1)])
		  ((= i len))
		(vector-set! nxt i (ftype-ref int () bufp i)))
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      nxt)))))

  (define sysctl-next-noskip
    (lambda (mib)
      (let* ([len (vector-length mib)]
	     [miblen (+ 2 len)]
	     [buflen (* (ftype-sizeof int) CTL_MAXNAME)]
	     [mibp (make-ftype-pointer int (foreign-alloc (* (ftype-sizeof int) miblen)))]
	     [bufp (make-ftype-pointer int (foreign-alloc buflen))]
	     [lenp (make-ftype-pointer size_t (foreign-alloc (ftype-sizeof size_t)))])
	(ftype-set! size_t () lenp buflen)
	(ftype-set! int () mibp 0 CTL_SYSCTL)
	(ftype-set! int () mibp 1 CTL_SYSCTL_NEXTNOSKIP)
	(do ([i 0 (+ i 1)])
	    ((= i len))
	  (ftype-set! int () mibp (+ 2 i) (vector-ref mib i)))
	(if (= -1 (sysctl mibp miblen (ftype-pointer-address bufp) lenp 0 0))
	    (let ([err (errno)])
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      (if (= err ENOENT)
		  #f
		  (raise (strerror err))))
	    (let* ([len (/ (ftype-ref size_t () lenp) (ftype-sizeof int))]
		   [nxt (make-vector len)])
	      (do ([i 0 (+ i 1)])
		  ((= i len))
		(vector-set! nxt i (ftype-ref int () bufp i)))
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      nxt)))))

  (define sysctl-name
    (lambda (mib)
      (let* ([len (vector-length mib)]
	     [miblen (+ 2 len)]
	     [mibp (make-ftype-pointer int (foreign-alloc (* (ftype-sizeof int) miblen)))]
	     [bufp (make-ftype-pointer char (foreign-alloc BUFSIZ))]
	     [lenp (make-ftype-pointer size_t (foreign-alloc (ftype-sizeof size_t)))])
	(ftype-set! size_t () lenp BUFSIZ)
	(ftype-set! int () mibp 0 CTL_SYSCTL)
	(ftype-set! int () mibp 1 CTL_SYSCTL_NAME)
	(do ([i 0 (+ i 1)])
	    ((= i len))
	  (ftype-set! int () mibp (+ 2 i) (vector-ref mib i)))
	(if (= -1 (sysctl mibp miblen (ftype-pointer-address bufp) lenp 0 0))
	    (let ([err (errno)])
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      (raise (strerror err)))
	    (let* ([len (ftype-ref size_t () lenp)]
		   [slen (- len 1)]
		   [name (make-string slen)])
	      (do ([i 0 (+ i 1)])
		  ((= i slen))
		(string-set! name i (ftype-ref char () bufp i)))
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      name)))))

  (define sysctl-description
    (lambda (mib)
      (let* ([len (vector-length mib)]
	     [miblen (+ 2 len)]
	     [mibp (make-ftype-pointer int (foreign-alloc (* (ftype-sizeof int) miblen)))]
	     [bufp (make-ftype-pointer char (foreign-alloc BUFSIZ))]
	     [lenp (make-ftype-pointer size_t (foreign-alloc (ftype-sizeof size_t)))])
	(ftype-set! size_t () lenp BUFSIZ)
	(ftype-set! int () mibp 0 CTL_SYSCTL)
	(ftype-set! int () mibp 1 CTL_SYSCTL_OIDDESCR)
	(do ([i 0 (+ i 1)])
	    ((= i len))
	  (ftype-set! int () mibp (+ 2 i) (vector-ref mib i)))
	(if (= -1 (sysctl mibp miblen (ftype-pointer-address bufp) lenp 0 0))
	    (let ([err (errno)])
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      (raise (strerror err)))
	    (let* ([len (ftype-ref size_t () lenp)]
		   [slen (- len 1)]
		   [desc (make-string slen)])
	      (do ([i 0 (+ i 1)])
		  ((= i slen))
		(string-set! desc i (ftype-ref char () bufp i)))
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      desc)))))

  (define sysctl-format
    (lambda (mib)
      (let* ([len (vector-length mib)]
	     [miblen (+ 2 len)]
	     [mibp (make-ftype-pointer int (foreign-alloc (* (ftype-sizeof int) miblen)))]
	     [bufp (make-ftype-pointer char (foreign-alloc BUFSIZ))]
	     [lenp (make-ftype-pointer size_t (foreign-alloc (ftype-sizeof size_t)))])
	(ftype-set! size_t () lenp BUFSIZ)
	(ftype-set! int () mibp 0 CTL_SYSCTL)
	(ftype-set! int () mibp 1 CTL_SYSCTL_OIDFMT)
	(do ([i 0 (+ i 1)])
	    ((= i len))
	  (ftype-set! int () mibp (+ 2 i) (vector-ref mib i)))
	(if (= -1 (sysctl mibp miblen (ftype-pointer-address bufp) lenp 0 0))
	    (let ([err (errno)])
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      (raise (strerror err)))
	    (let* ([len (ftype-ref size_t () lenp)]
		   [fmtoff (ftype-sizeof unsigned-int)]
		   [slen (- len 1 fmtoff)]
		   [kind (ftype-ref unsigned-int () (make-ftype-pointer unsigned-int (ftype-pointer-address bufp)) 0)]
		   [fmt (make-string slen)])
	      (do ([i 0 (+ i 1)])
		  ((= i slen))
		(string-set! fmt i (ftype-ref char () bufp (+ fmtoff i))))
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      (cons kind fmt))))))

  (define sysctl-label
    (lambda (mib)
      (let* ([len (vector-length mib)]
	     [miblen (+ 2 len)]
	     [mibp (make-ftype-pointer int (foreign-alloc (* (ftype-sizeof int) miblen)))]
	     [bufp (make-ftype-pointer char (foreign-alloc BUFSIZ))]
	     [lenp (make-ftype-pointer size_t (foreign-alloc (ftype-sizeof size_t)))])
	(ftype-set! size_t () lenp BUFSIZ)
	(ftype-set! int () mibp 0 CTL_SYSCTL)
	(ftype-set! int () mibp 1 CTL_SYSCTL_OIDLABEL)
	(do ([i 0 (+ i 1)])
	    ((= i len))
	  (ftype-set! int () mibp (+ 2 i) (vector-ref mib i)))
	(if (= -1 (sysctl mibp miblen (ftype-pointer-address bufp) lenp 0 0))
	    (let ([err (errno)])
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      (raise (strerror err)))
	    (let* ([len (ftype-ref size_t () lenp)]
		   [slen (- len 1)]
		   [desc (make-string slen)])
	      (do ([i 0 (+ i 1)])
		  ((= i slen))
		(string-set! desc i (ftype-ref char () bufp i)))
	      (foreign-free (ftype-pointer-address mibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      desc)))))

  (define sysctl-get
    (lambda (mib)
      (let* ([len (vector-length mib)]
	     [qmiblen (+ 2 len)]
	     [qmibp (make-ftype-pointer int (foreign-alloc (* (ftype-sizeof int) qmiblen)))]
	     [bufp (make-ftype-pointer unsigned-int (foreign-alloc BUFSIZ))]
	     [lenp (make-ftype-pointer size_t (foreign-alloc (ftype-sizeof size_t)))])
	(ftype-set! size_t () lenp BUFSIZ)
	(ftype-set! int () qmibp 0 CTL_SYSCTL)
	(ftype-set! int () qmibp 1 CTL_SYSCTL_OIDFMT)
	(do ([i 0 (+ i 1)])
	    ((= i len))
	  (ftype-set! int () qmibp (+ 2 i) (vector-ref mib i)))
	;; check the format
	(if (= -1 (sysctl qmibp qmiblen (ftype-pointer-address bufp) lenp 0 0))
	    (let ([err (errno)])
	      (foreign-free (ftype-pointer-address qmibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      (raise (strerror err))))
	(let* ([kind (ftype-ref unsigned-int () bufp)]
	       [type (bitwise-and kind CTLTYPE)]
	       [mibp (ftype-&ref int () qmibp 2)])
	  (foreign-free (ftype-pointer-address bufp))
	  (if (equal? type #x1)	; CTLTYPE_NODE
	      (begin
		(foreign-free (ftype-pointer-address qmibp))
		(foreign-free (ftype-pointer-address lenp))
		'node)
	      (begin
		(ftype-set! size_t () lenp 0)
		;; check the value size (FIXME: redundant for most types)
		(if (= -1 (sysctl mibp len 0 lenp 0 0))
		    (let ([err (errno)])
		      (foreign-free (ftype-pointer-address qmibp))
		      (foreign-free (ftype-pointer-address lenp))
		      (raise (strerror err))))
		(let* ([buflen (+ 1 (* 2 (ftype-ref size_t () lenp)))] ; in case it grew
		       [bufp (foreign-alloc buflen)])
		  (ftype-set! size_t () lenp buflen)
		  ;; get the value in a buffer
		  (if (= -1 (sysctl mibp len bufp lenp 0 0))
		      (let ([err (errno)])
			(foreign-free (ftype-pointer-address qmibp))
			(foreign-free (ftype-pointer-address lenp))
			(foreign-free bufp)
			(raise (strerror err))))
		  ;; get the value from the buffer
		  (let ([obj (case type
			       ;; CTLTYPE_INT
			       [#x2 (foreign-ref 'int bufp 0)]
			       ;; CTLTYPE_STRING
			       [#x3 (let* ([slen (- (ftype-ref size_t () lenp) 1)]
					   [s (make-string slen)])
				      (do ([i 0 (+ i 1)])
					  ((= i slen))
					(string-set! s i (foreign-ref 'char bufp i)))
				      s)]
			       ;; CTLTYPE_S64
			       [#x4 (foreign-ref 'integer-64 bufp 0)]
			       ;; CTLTYPE_OPAQUE (FIXME: handle some structs like sysctl(8))
			       [#x5 (let* ([vlen (ftype-ref size_t () lenp)]
					   [v (make-bytevector vlen)])
				      (do ([i 0 (+ i 1)])
					  ((= i vlen))
					(bytevector-u8-set! v i (foreign-ref 'unsigned-8 bufp i)))
				      v)]
			       ;; CTLTYPE_UINT
			       [#x6 (foreign-ref 'unsigned-int bufp 0)]
			       ;; CTLTYPE_LONG
			       [#x7 (foreign-ref 'long bufp 0)]
			       ;; CTLTYPE_ULONG
			       [#x8 (foreign-ref 'unsigned-long bufp 0)]
			       ;; CTLTYPE_U64
			       [#x9 (foreign-ref 'unsigned-64 bufp 0)]
			       ;; CTLTYPE_U8
			       [#xa (foreign-ref 'unsigned-8 bufp 0)]
			       ;; CTLTYPE_U16
			       [#xb (foreign-ref 'unsigned-16 bufp 0)]
			       ;; CTLTYPE_S8
			       [#xc (foreign-ref 'integer-8 bufp 0)]
			       ;; CTLTYPE_S16
			       [#xd (foreign-ref 'integer-16 bufp 0)]
			       ;; CTLTYPE_S32
			       [#xe (foreign-ref 'integer-32 bufp 0)]
			       ;; CTLTYPE_U32
			       [#xf (foreign-ref 'unsigned-32 bufp 0)])])
		    (foreign-free (ftype-pointer-address qmibp))
		    (foreign-free (ftype-pointer-address lenp))
		    (foreign-free bufp)
		    obj))))))))

  (define sysctl-set
    (lambda (mib value)
      (let* ([len (vector-length mib)]
	     [qmiblen (+ 2 len)]
	     [qmibp (make-ftype-pointer int (foreign-alloc (* (ftype-sizeof int) qmiblen)))]
	     [bufp (make-ftype-pointer unsigned-int (foreign-alloc BUFSIZ))]
	     [lenp (make-ftype-pointer size_t (foreign-alloc (ftype-sizeof size_t)))])
	(ftype-set! size_t () lenp BUFSIZ)
	(ftype-set! int () qmibp 0 CTL_SYSCTL)
	(ftype-set! int () qmibp 1 CTL_SYSCTL_OIDFMT)
	(do ([i 0 (+ i 1)])
	    ((= i len))
	  (ftype-set! int () qmibp (+ 2 i) (vector-ref mib i)))
	;; check the format
	(if (= -1 (sysctl qmibp qmiblen (ftype-pointer-address bufp) lenp 0 0))
	    (let ([err (errno)])
	      (foreign-free (ftype-pointer-address qmibp))
	      (foreign-free (ftype-pointer-address bufp))
	      (foreign-free (ftype-pointer-address lenp))
	      (raise (strerror err))))
	(let* ([kind (ftype-ref unsigned-int () bufp)]
	       [type (bitwise-and kind CTLTYPE)]
	       [mibp (ftype-&ref int () qmibp 2)])
	  (foreign-free (ftype-pointer-address bufp))
	  (foreign-free (ftype-pointer-address lenp))
	  (if (equal? type #x1)	; CTLTYPE_NODE
	      ;; can't set a node (not enough type info to call nodes with handlers)
	      (begin
		(foreign-free (ftype-pointer-address qmibp))
		(raise (strerror EISDIR)))
	      ;; else fill a buffer and set
	      (let* ([size (case type
			     ;; CTLTYPE_INT
			     [#x2 (foreign-sizeof 'int)]
			     ;; CTLTYPE_STRING
			     [#x3 (+ 1 (string-length value))]
			     ;; CTLTYPE_S64
			     [#x4 (foreign-sizeof 'integer-64)]
			     ;; CTLTYPE_OPAQUE
			     [#x5 (bytevector-length value)]
			     ;; CTLTYPE_UINT
			     [#x6 (foreign-sizeof 'unsigned-int)]
			     ;; CTLTYPE_LONG
			     [#x7 (foreign-sizeof 'long)]
			     ;; CTLTYPE_ULONG
			     [#x8 (foreign-sizeof 'unsigned-long)]
			     ;; CTLTYPE_U64
			     [#x9 (foreign-sizeof 'unsigned-64)]
			     ;; CTLTYPE_U8
			     [#xa (foreign-sizeof 'unsigned-8)]
			     ;; CTLTYPE_U16
			     [#xb (foreign-sizeof 'unsigned-16)]
			     ;; CTLTYPE_S8
			     [#xc (foreign-sizeof 'integer-8)]
			     ;; CTLTYPE_S16
			     [#xd (foreign-sizeof 'integer-16)]
			     ;; CTLTYPE_S32
			     [#xe (foreign-sizeof 'integer-32)]
			     ;; CTLTYPE_U32
			     [#xf (foreign-sizeof 'unsigned-32)])]
		     [bufp (foreign-alloc size)])
		(case type
		  ;; CTLTYPE_INT
		  [#x2 (foreign-set! 'int bufp 0 value)]
		  ;; CTLTYPE_STRING
		  [#x3 (let ([n (- size 1)])
			 (do ([i 0 (+ i 1)])
			     ((= i n))
			   (foreign-set! 'char bufp i (string-ref value i)))
			 (foreign-set! 'char bufp n #\nul))]
		  ;; CTLTYPE_S64
		  [#x4 (foreign-set! 'integer-64 bufp 0 value)]
		  ;; CTLTYPE_OPAQUE
		  [#x5 (do ([i 0 (+ i 1)])
			   ((= i size))
			 (foreign-set! 'unsigned-8 bufp i (bytevector-u8-ref value i)))]
		  ;; CTLTYPE_UINT
		  [#x6 (foreign-set! 'unsigned-int bufp 0 value)]
		  ;; CTLTYPE_LONG
		  [#x7 (foreign-set! 'long bufp 0 value)]
		  ;; CTLTYPE_ULONG
		  [#x8 (foreign-set! 'unsigned-long bufp 0 value)]
		  ;; CTLTYPE_U64
		  [#x9 (foreign-set! 'unsigned-64 bufp 0 value)]
		  ;; CTLTYPE_U8
		  [#xa (foreign-set! 'unsigned-8 bufp 0 value)]
		  ;; CTLTYPE_U16
		  [#xb (foreign-set! 'unsigned-16 bufp 0 value)]
		  ;; CTLTYPE_S8
		  [#xc (foreign-set! 'integer-8 bufp 0 value)]
		  ;; CTLTYPE_S16
		  [#xd (foreign-set! 'integer-16 bufp 0 value)]
		  ;; CTLTYPE_S32
		  [#xe (foreign-set! 'integer-32 bufp 0 value)]
		  ;; CTLTYPE_U32
		  [#xf (foreign-set! 'unsigned-32 bufp 0 value)])
		(if (= -1 (sysctl mibp len 0 (make-ftype-pointer size_t 0) bufp size))
		    (let ([err (errno)])
		      (foreign-free (ftype-pointer-address qmibp))
		      (foreign-free bufp)
		      (raise (strerror err))))
		(foreign-free (ftype-pointer-address qmibp))
		(foreign-free bufp)))))))

  (define sysctl-list
    (lambda (mib)
      (let* ([l (list)]
	     [miblen (vector-length mib)]
	     [prefix-match (lambda (m)
			     (and (vector? m)
				  (<= miblen (vector-length m))
				  (equal? mib (vector-copy m 0 miblen))))])
	(do ([m mib (sysctl-next m)])
	    ((not (prefix-match m)))
	  (set! l (append! l (list m))))
	l)))

  (define sysctl-list-noskip
    (lambda (mib)
      (let* ([l (list)]
	     [miblen (vector-length mib)]
	     [prefix-match (lambda (m)
			     (and (vector? m)
				  (<= miblen (vector-length m))
				  (equal? mib (vector-copy m 0 miblen))))])
	(do ([m mib (sysctl-next-noskip m)])
	    ((not (prefix-match m)))
	  (set! l (append! l (list m))))
	l)))

  (define sysctl-all
    (lambda ()
      (let ([l (list)])
	(do ([m '#(1) (sysctl-next m)])
	    ((not (vector? m)))
	  (set! l (append! l (list m))))
	l)))

  (define sysctl-all-noskip
    (lambda ()
      (let ([l (list)])
	(do ([m '#(1) (sysctl-next-noskip m)])
	    ((not (vector? m)))
	  (set! l (append! l (list m))))
	l)))
  )
