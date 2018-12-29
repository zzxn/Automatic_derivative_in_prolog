% derivative

deriv(U, X, DU) :- !, sim(U, SU), d(SU, X, NSDU), sim(NSDU, DU).

d(U, X, 0) :- independent(U, X), !.
d(X, X, 1) :- !.
d(+U, X, DU) :- !, d(U, X, DU).
d(-U, X, -DU) :- !, d(U, X, DU).

d(U + V, X, DU + DV) :- !, d(U, X, DU), d(V, X, DV).
d(U - V, X, DU - DV) :- !, d(U, X, DU), d(V, X, DV).
d(U * V, X, DU * V + U * DV) :- !, d(U, X, DU), d(V, X, DV).
d(U / V, X,(DU * V - U * DV)/(V^2)) :- !, d(U, X, DU), d(V, X, DV).

d(N^U, X, DU * N^U * ln(N)) :- independent(N, X), !, d(U, X, DU).
d(U^N, X, DU * N * U^(N-1)) :- independent(N, X), !, d(U, X, DU).

d(exp(U), X, exp(U) * DU) :- !, d(U, X, DU).
d(ln(U), X, DU / U) :- !, d(U, X, DU).
d(log2(U), X, Y) :- !, d(log(U, 2), X, Y).
d(log10(U), X, Y) :- !, d(log(U, 10), X, Y).
d(log(U, N), X, DU / (U * ln(N))) :- independent(N, X), !, d(U, X, DU).

d(sin(U), X, cos(U) * DU) :- !, d(U, X, DU).
d(cos(U), X, -sin(U) * DU) :- !, d(U, X, DU).
d(tan(U), X, (sec(U)^2) * DU) :- !, d(U, X, DU).
d(asin(U), X, DU / sqrt(1 - U^2)) :- !, d(U, X, DU).
d(acos(U), X, -DU / sqrt(1 - U^2)) :- !, d(U, X, DU).
d(atan(U), X, DU / (1 + U^2)) :- !, d(U, X, DU).

d(sigmoid(U), X, (sigmoid(U) * (1 - sigmoid(U))) * DU) :- !, d(U, X, DU).
d(relu(U), X, sign(relu(U)) * DU) :- !, d(U, X, DU).

d(_, _, unknown) :- !.

independent(Y, X) :- Y =.. [Op|Vars], X \= Op, independent_any_of(X, Vars).
independent_any_of(X, [Y|Vars]) :- independent(Y, X), independent_any_of(X, Vars). 
independent_any_of(_, []).

% simplify

sim(+X, R) :- !, sim(X, R).
sim(-X, -R) :- !, sim(X, R).

sim(X + Y, R) :- !, sim(X, SX), sim(Y, SY), simplus(SX, SY, R).
sim(X - Y, R) :- !, sim(X, SX), sim(Y, SY), simminus(SX, SY, R).
sim(X * Y, R) :- !, sim(X, SX), sim(Y, SY), simmul(SX, SY, R).
sim(X / Y, R) :- !, sim(X, SX), sim(Y, SY), simdiv(SX, SY, R).

sim(X^1, R) :- !, sim(X, R).
sim(_^0, 1) :- !.
sim(X^Y, R) :- !, sim(X, SX), sim(Y, SY), simgeneralexp(SX^SY, R).
simgeneralexp(X^1, R) :- !, sim(X, R).
simgeneralexp(_^0, 1) :- !.
simgeneralexp(X^Y, X^Y) :- !.

sim(exp(X), exp(SX)) :- !, sim(X, SX).
sim(ln(X), ln(SX)) :- !, sim(X, SX).
sim(log2(X), log2(SX)) :- !, sim(X, SX).
sim(log10(X), log10(SX)) :- !, sim(X, SX).
sim(log(X, Y), log(SX, SY)) :- !, sim(X, SX), sim(Y, SY).

sim(sin(X), sin(SX)) :- !, sim(X, SX).
sim(cos(X), cos(SX)) :- !, sim(X, SX).
sim(tan(X), tan(SX)) :- !, sim(X, SX).
sim(asin(X), asin(SX)) :- !, sim(X, SX).
sim(acos(X), acos(SX)) :- !, sim(X, SX).
sim(atan(X), atan(SX)) :- !, sim(X, SX).

sim(sigmoid(X), sigmoid(SX)) :- !, sim(X, SX).
sim(relu(X), relu(SX)) :- !, sim(X, SX).

sim(X, X) :- !.

% simplify plus

simplus(0, X, X) :- !.
simplus(X, 0, X) :- !.

simplus(X, Y, R) :- integer(X), integer(Y), !, R is X + Y.

simplus(A + X, Y, R) :- integer(A), !, simplus(X + A, Y, R).
simplus(X, B + Y, R) :- integer(B), !, simplus(X, Y + B, R).
simplus(A + X, B + Y, R) :- integer(A), integer(B), !, simplus(X + A, Y + B, R).

simplus(X + A, B, X + C) :- integer(A), integer(B), !, C is A + B.
simplus(X + A, Y, R + A) :- integer(A), !, simplus(X, Y, R).
simplus(X, Y + B, R + B) :- integer(B), !, simplus(X, Y, R).

simplus(X * A, Y, R) :- integer(A), !, simplus(A * X, Y, R).
simplus(X, Y * B, R) :- integer(B), !, simplus(X, B * Y, R).
simplus(X * A, Y * B, R) :- integer(A), integer(B), simplus(A * X, B * Y, R).

simplus(X, X, 2 * X) :- !.
simplus(A * X, X, C * X) :- integer(A), !, C is A + 1.
simplus(X, B * X, C * X) :- integer(B), !, C is B + 1.
simplus(A * X, B * X, C * X) :- integer(A), integer(B), !, C is A + B.

simplus(X, Y, X + Y) :- !.

% simplify minus

simminus(X, 0, X) :- !.
simminus(0, X, -X) :- !.
simminus(X, X, 0) :- !.
simminus(X, Y, R) :- integer(X), integer(Y), !, R is X - Y.
simminus(X, A, R) :- number(A), A < 0, !, B is -A, simplus(X, B, R).

simminus(X, Y, X - Y) :- !.

% simplify multiply

simmul(X, Y, 0) :- (X = 0; Y = 0), !.
simmul(1, X, X) :- !.
simmul(X, 1, X) :- !.
simmul(-1, X, -X) :- !.
simmul(X, -1, -X) :- !.
simmul(X, Y, R) :- integer(X), integer(Y), !, R is X * Y.

simmul(A * X, B, C * X) :- integer(A), integer(B), !, C is A * B.
simmul(A, B * X, C * X) :- integer(A), integer(B), !, C is A * B.
simmul(A * X, B * Y, C * R) :- integer(A), integer(B), !, C is A * B, sim(X * Y, R).

simmul(X, X, X^2) :- !.
simmul(X, X^B, X^C) :- !, simplus(B, 1, C).
simmul(X^A, X, X^C) :- !, simplus(A, 1, C).
simmul(X^A, X^B, X^C) :- !, simplus(A, B, C).

simmul(A + B, X, R1 + R2) :- !, sim(A * X, R1), sim(B * X, R2).
simmul(A - B, X, R1 - R2) :- !, sim(A * X, R1), sim(B * X, R2).
simmul(X, A + B, R1 + R2) :- !, sim(A * X, R1), sim(B * X, R2).
simmul(X, A - B, R1 - R2) :- !, sim(A * X, R1), sim(B * X, R2).

simmul(X, Y, X * Y) :- !.

% simplify divide

simdiv(0, _, 0) :- !.
simdiv(X, 1, X) :- !.
simdiv(X, X, 1) :- !.

simdiv(X * Y, X, Y) :- !.
simdiv(X * Y, Y, X) :- !.

simdiv(X + Y, Z, R1 + R2) :- !, sim(X / Z, R1), sim(Y / Z, R2).
simdiv(X - Y, Z, R1 - R2) :- !, sim(X / Z, R1), sim(Y / Z, R2).

simdiv(X^Y, X, R) :- !, sim(X^(Y - 1), R).
simdiv(X^A, X^B, R) :- !, sim(X^(A - B), R).

simdiv(X / Y, Z, R) :- !, sim(X / (Y * Z), R).
simdiv(-(X / Y), Z, -R) :- !, sim(X / (Y * Z), R). 

simdiv(X, Y, X / Y) :- !.