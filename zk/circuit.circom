pragma circom 2.0.2;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template ArgMax (n) {
    signal input in[n];
    signal output out;
    component gts[n];        // store comparators
    component switchers[n+1];  // switcher for comparing maxs
    component aswitchers[n+1]; // switcher for arg max

    signal maxs[n+1];
    signal amaxs[n+1];

    maxs[0] <== in[0];
    amaxs[0] <== 0;
    for(var i = 0; i < n; i++) {
        gts[i] = GreaterThan(30);
        switchers[i+1] = Switcher();
        aswitchers[i+1] = Switcher();

        gts[i].in[1] <== maxs[i];
        gts[i].in[0] <== in[i];

        switchers[i+1].sel <== gts[i].out;
        switchers[i+1].L <== maxs[i];
        switchers[i+1].R <== in[i];
        
        aswitchers[i+1].sel <== gts[i].out;
        aswitchers[i+1].L <== amaxs[i];
        aswitchers[i+1].R <== i;
        amaxs[i+1] <== aswitchers[i+1].outL;
        maxs[i+1] <== switchers[i+1].outL;
    }

    out <== amaxs[n];
}

// image is non-negative 50x1 shape matrix, output from prior NN layers 
// A is final layer of NN, ndigitsx50 shape matrix
template DigitReader (n) {
    signal input image[n]; // must be non-negative
    signal output digit;
    var ndigits = 10;
    var A[ndigits][n] = [[-108,  143,  -43, -115,  102,  -21,  244,    3,   97,  -62, -184,
          -6,  162,   49,  120,  109, -173,   26,   -1, -274,   87,  -44,
          30,    5,  102,   57, -123,  156,  141, -161,   91,   92, -144,
          94,  100, -210, -162,    5,  137,  -85,   47, -210,  -71,   19,
         -13,  -84, -226,  150,  124,   37],
       [  -8,  -65,   93,  -87,  -77,  -69, -182, -238,  186, -292,  -33,
          57,  -50,  190,  -58, -129,   40, -239,  -83,   26, -116,  262,
        -104,  126, -251, -126,   -2,  159,  320,  -97,  131,  -91,  101,
          57,  -86,  272,  100,    0, -175, -185,  163,   80,  -92,  -58,
          82, -184, -125,   93,  -81,  -58],
       [ 120, -103,   33, -197,  -40,  -70,  133,   17, -228, -167,  -91,
         291,  142,   -3,   48,    5,  192,  -98, -186,  172,  113,   51,
          75, -161,  -43,   93,  126,   58,  286, -209,   57,  132, -183,
        -188,  255,   12, -178,   49,  -91,  -31, -225, -162,  -69, -188,
          25,    9,  -72, -203, -137,   -7],
       [  74,  132,  251,   95,  -91,  -28, -123,   67,  168,   75,  131,
          11,  116, -182,  -48,  136, -182,  -30,  -64,  201, -102, -165,
          93, -175, -112,  239,   61,  -73, -235,  242, -169,  -40,  153,
        -138,   87,  156,  -81,  -85,  -78, -229,  269, -145,  -79,   55,
        -129, -133,  -58, -188,  111, -191],
       [  18,  128, -109,  -86,   -9,   17, -255, -203,   25,   34,  100,
        -199,   98,  149,  -47,  152,  257,    7,    4, -198,  -18,  173,
           6, -187, -189, -275,  136,   70,   -1,   81,   92,   78,  184,
          98,  124, -162,  255, -120,   70,  116, -264,   78, -116,    4,
         -59,  210,   60,  102,  138,   96],
       [ -55, -134,  183,  224,   86,  -50, -203,   91,  216, -109, -104,
        -210,  172,   70, -115, -196, -194,  135,   76, -101, -112, -131,
         -94,  234,  102,   60,   60,  -82, -244, -169,  121,  112, -102,
         160,   84,  106,  -99,  206,   87,  203,  -63,  207,   25,   87,
        -140,   42,   20,   28,  -46, -208],
       [-107,  234, -155,  123,   57,  -94,  173,  120,   -2,   21,   28,
         -53,  186, -160, -114, -231,  132,  214,  -36, -110,   70,   10,
          27,  -32,  113, -129, -138, -194,  -72, -210,    0,   34,  131,
         166, -359,  124,   -5,  -24,   30,  258,   52, -169,  -87, -133,
         126,  217, -290,  -65, -153,  103],
       [-158,  -63,   77, -117,  -83,  110, -102,   65, -198, -110,  311,
          58,  -73,  -55,  126,  -25, -155,  -44,    8, -201,  -83,  209,
         -63, -227,  -83,   -1,   24,  137,  207,   34,  -37,   39, -202,
         153,  200,  146, -180, -321,   11,   75,   68,  194,  128,   34,
          71, -267,  183,  201, -146,  181],
       [  84, -129,   16, -147,  105,   88,  197,   55, -243,  -32, -225,
         -71,  -26,  -95, -160,   68,  -29,  -83,  -53,  162,  -21, -335,
          97,  282,   33,  -32,  -41, -168,   71,  220, -130,  -90,  132,
        -269, -138,  -74, -106,   44, -133,   93,  -60,   99,   38,  -44,
         135,  134,  162,  -52,  168,   62],
       [-337,   56,  -64,   18,   75,   65, -246,  204,   83,  299,   19,
        -241, -112,   28,  124,  245,   12,   31,  105,  192,  -48,   24,
        -140,  -43,  188, -139,  115,  101, -278,  268,  118, -104,   20,
           0,   38, -290, -143,  100, -108, -137,    2,    4,   47,   40,
        -119,  -90,  118,  163, -121,   99]];

    var B[ndigits] =[  45987,   60763,  -97298, -140355,  -85216,   13935,  -46256,
        -49615,  -12346,  -34550]; 
    signal s[ndigits][n+1];
    component am = ArgMax(ndigits);
    for(var i=0; i<ndigits; i++){
        s[i][0] <== 0;
        for(var j=1; j<=n; j++){
            s[i][j] <== s[i][j-1] + A[i][j-1]*image[j-1] - 10000*A[i][j-1];
        }
        am.in[i] <== s[i][n]+B[i] + 10000000;
        log(am.in[i]);
    }
    am.out ==> digit;
}

component main = DigitReader(50);

/* INPUT = {
  "image": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 36, 125, 191, 218, 255, 254, 254, 241, 51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 204, 249, 253, 253, 253, 253, 253, 253, 253, 250, 235, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 88, 241, 251, 253, 225, 142, 49, 12, 12, 12, 105, 253, 253, 111, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 95, 225, 253, 167, 113, 14, 0, 0, 0, 0, 0, 16, 211, 253, 117, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 91, 238, 253, 170, 28, 0, 0, 0, 0, 0, 0, 0, 0, 150, 253, 117, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 98, 251, 218, 48, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 150, 253, 117, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 112, 253, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 184, 242, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 45, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 67, 253, 240, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 234, 248, 105, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 44, 157, 253, 132, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 189, 253, 203, 27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 156, 253, 246, 77, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 156, 253, 202, 68, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 156, 253, 226, 71, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 30, 33, 33, 140, 163, 186, 253, 226, 38, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 81, 244, 253, 253, 253, 253, 253, 253, 253, 186, 70, 23, 0, 0, 22, 156, 77, 0, 0, 0, 0, 0, 0, 0, 0, 0, 80, 195, 253, 253, 253, 253, 253, 248, 234, 166, 248, 253, 253, 240, 150, 73, 144, 104, 51, 0, 0, 0, 0, 0, 0, 0, 0, 7, 248, 253, 253, 253, 253, 253, 242, 105, 0, 0, 107, 242, 253, 253, 253, 245, 160, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 57, 250, 253, 253, 253, 247, 135, 21, 0, 0, 0, 0, 21, 117, 183, 183, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 121, 123, 176, 135, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
} */
