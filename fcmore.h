#ifndef FCMORE_HEADER
#define FCMORE_HEADER

struct _FcStrSet {
    int		    ref;	/* reference count */
    int		    num;
    int		    size;
    FcChar8	    **strs;
};

#endif
