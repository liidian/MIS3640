(* 

HOMEWORK 7

Name: Ching Chiu Huang

Email:chuang2@babson.edu

Remarks, if any:

*)
module Lambda = struct

  type lterm = 
      LIdent of string
    | LLam of string * lterm
    | LApp of lterm * lterm

  let fresh =
    let tag = ref 0 in
    fun id ->
      let new_id = id^"_"^(string_of_int (!tag)) in
      ( tag := (!tag) + 1; new_id)

  let lexer = Genlex.make_lexer ["(";")";"<";"->";">"]

  let explode str = 
    let rec acc index result = 
      if (index<0) then result
      else acc (index-1) ((String.sub str index 1)::result) in
    acc (String.length(str)-1) []

  let canonicalize s = 
    (* urgh! dirty hack, but the aim is to produce something quickly *)
    (* replace every ">" and "<" by "> " and "> " so that the lexer  *)
    (* actually works since it doesn't want to split ">>" *)
   let sl = explode s  in
   let sl' = List.map (fun s -> match s with "<" -> "< " | ">" -> "> " | _ -> s) sl in
   List.fold_left (fun acc s -> acc^s) "" sl'

  let lex s = 
    let str = lexer (Stream.of_string s)  in
    let rec loop () = 
      match (Stream.peek str) with
      | None -> []
      | Some _ -> let elt = Stream.next str in elt::(loop())  in
    loop ()

  let expect elt cs = 
    match cs with
    | f::cs when f = elt -> Some cs
    | _ -> None

  let expect_ident cs = 
    match cs with
    | (Genlex.Ident id)::cs -> Some (id,cs)
    | _ -> None

  let rec makeApps terms = 
    match terms with
    | [] -> failwith "Parsing error! [makeApps with empty list]"
    | [t] -> t
    | t1::t2::ts -> makeApps (LApp(t1,t2)::ts)

  let rec parse_terms cs = 
    match parse_term cs with
    | Some (t,cs) -> 
	(match parse_terms cs with
	| Some (ts,cs) -> Some (t::ts,cs)
        | None -> Some ([t],cs))
    | None -> None

  and parse_term cs = 
    match parse_ident cs with
    | Some x -> Some x
    | None -> 
	(match parse_lambda cs with
	|	Some x -> Some x
	|	None ->
	    (match parse_group cs with
	    | Some x -> Some x
	    | None -> None))

  and parse_ident cs =
    match expect_ident cs with
    | None -> None
    | Some (id,cs) -> Some (LIdent id,cs)

  and parse_lambda cs = 
    match expect (Genlex.Kwd "<") cs with
    | None -> None
    | Some cs -> 
	(match expect_ident cs with
	|	None -> None
	|	Some (id,cs) -> 
	    (match expect (Genlex.Kwd "->") cs with
	    | None -> None
	    | Some cs -> 
		(match parse_terms cs with
		|	None -> None
		|	Some (terms,cs) ->
		    (match expect (Genlex.Kwd ">") cs with
		    | None -> None
		    | Some cs -> Some (LLam (id,makeApps(terms)),cs)))))

  and parse_group cs =
    match expect (Genlex.Kwd "(") cs with
    | None -> None
    | Some cs ->
	(match parse_terms cs with
	|	None -> None
	|	Some (terms,cs) ->
	    (match expect (Genlex.Kwd ")") cs with
	    | None -> None
	    | Some cs -> Some (makeApps(terms),cs)))


  let parse str = 
    match parse_terms (lex (canonicalize str)) with
    | Some (terms,[]) -> makeApps(terms)
    | _ -> failwith ("Cannot parse "^str)

  let rec pp term = 
    match term with
    | LIdent x -> x
    | LLam (x,t) -> "<"^x^" -> "^(pp t)^">"
    | LApp (t1,t2) -> 
       let t2' = (match t2 with
       | LApp _ -> "("^(pp t2)^")"
       | _ -> (pp t2))  in
       (pp t1)^" "^t2'

  let rec rename term old nw = 
    match term with
    | LIdent x when x = old -> LIdent nw
    | LIdent x -> LIdent x
    | LLam (x,t) when x = old  -> LLam (x,t)
    | LLam (x,t) -> LLam (x, rename t old nw)
    | LApp (t1,t2) -> LApp (rename t1 old nw,
			    rename t2 old nw)

  let rec fv m = 
    match m with
    | LIdent x -> [x]
    | LLam (x,t) -> List.filter (fun y -> x <> y) (fv t)
    | LApp (t1,t2) -> (fv t1) @ (fv t2)

  let rec substitute m s n = 
    match m with
    | LIdent x when x = s -> n
    | LIdent x -> LIdent x
    | LLam (x,t) when x = s -> LLam (x,t)
    | LLam (x,t) when List.mem x (fv n) -> 
	let x_ = fresh x in
	substitute (LLam (x_,rename t x x_)) s n
    | LLam (x,t) -> LLam (x,substitute t s n)
    | LApp (t1,t2) -> LApp (substitute t1 s n,
			    substitute t2 s n)

  let rec reduce term = 
    match term with
    | LIdent s -> None
    | LLam (s,term) -> 
	(match reduce term with
	|	None -> None
	|	Some t -> Some (LLam(s,t)))
    | LApp (LLam (s,term1),term2) -> 
	Some (substitute term1 s term2)
    | LApp (term1,term2) -> 
	(match reduce term1 with
	|	None -> (match reduce term2 with
      	  | None -> None
	  | Some t2 -> Some (LApp (term1,t2)))
	|	Some t1 -> Some (LApp (t1,term2)))

  let expand_all defs = 
    let expand defs t = List.fold_left (fun r (n,d) -> substitute r n d) t defs in
    let rec loop done_defs defs = 
      match defs with
      | [] -> done_defs
      | (name,df)::dfs -> loop ((name,expand done_defs df)::done_defs) dfs  in
    loop [] defs

  let threshold = 5000

  let simplify' print_term defs term = 
    let term = parse term  in
    let expand defs t = List.fold_left (fun r (n,d) -> substitute r n d) t defs in
    let defs = expand_all (List.map (fun (n,d) -> (n,parse d)) defs) in
    let term = expand defs term  in
    let rec loop n term =  
      let _ = print_term (" = "^(pp term)) in
      if n > threshold
      then failwith ("failed to find normal form after "^(string_of_int threshold)^" simplifications")
      else 
	match (reduce term) with
	| None -> pp term
	|	Some term -> loop (n+1) term  in
    match reduce term with
    | None -> let _ = print_endline "Term already in normal form" in (pp term)
    | Some next -> let _ = print_term ("   "^(pp term))  in loop 0 next

end




(*
 * Simplification of lambda terms
 *
 * One version that simply returns the result
 * One version that prints all intermediate terms
 *
 *)

let simplify_verbose defs term = Lambda.simplify' print_endline defs term

let simplify defs term = Lambda.simplify' (fun t -> ()) defs term


(* 
 * The default definitions from class
 *
 *)

let default_defs = [ 
   ("true","<x -> <y -> x>>");
   ("false","<x -> <y -> y>>");
   ("if","<c -> <x -> <y -> c x y>>>");
   ("and","<b -> <c -> b c false>>");
   ("or","<b -> <c -> b true c>>");
   ("not","<b -> b false true>");
   ("_0","<f -> <x -> x>>");
   ("_1","<f -> <x -> f x>>");
   ("_2","<f -> <x -> f (f x)>>");
   ("_3","<f -> <x -> f (f (f x))>>");
   ("_4","<f -> <x -> f (f (f (f x)))>>");
   ("_5","<f -> <x -> f (f (f (f (f x))))>>");
   ("succ","<n -> <f -> <x -> (n f) (f x)>>>");
   ("plus","<m -> <n -> <f -> <x -> (m f) (n f x)>>>>");
   ("times","<m -> <n -> <f -> <x -> m (n f) x>>>>");
   ("iszero","<n -> n <x -> false> true>");
   ("pred","<n -> <f -> <x -> n <g -> <h -> h (g f)>> <u -> x> <u -> u>>>>");
   ("minus","<n -> <m -> m pred n>>");
   ("geq","<m -> <n -> not (iszero (minus (succ m) n))>>");
   ("pair","<x -> <y -> <s -> s x y>>>");
   ("pfirst","<p -> p <x -> <y -> x>>>");
   ("psecond","<p -> p <x -> <y -> y>>>");
   ("Y","<f -> <x -> f (x x)> <x -> f (x x)>>");
   ("fact","Y <fact -> <n -> (iszero n) _1 (times n (fact (pred n)))>>")
 ]
   


(*************************************************************
 * Question 1
 *
 *************************************************************)

(*
 * By default, all of these are implemented as identifier "not_implemented"
 * 
 * Just replace that with your own definition
 *
 *)

simplify_verbose default_defs "plus _4 _4";;

let int = ("int","pair true")

let neg_int = ("neg_int","not_implemented")

let plus_int = ("plus_int","not_implemented")

let times_int = ("times_int","not_implemented")


(* 
 * Make sure all your definitions are added to this -- 
   this is what I'll be testing 
 * 
 *)

let q1_defs : (string * string) list = 
   default_defs @ [int; neg_int; plus_int; times_int ]



(*************************************************************
 * Question 2
 *
 *************************************************************)

(*
 * By default, all of these are implemented as identifier "not_implemented"
 * 
 * Just replace that with your own definition
 *
 *)

let triple = ("triple", "not_implemented")
let tfirst = ("tfirst", "not_implemented")
let tsecond = ("tsecond", "not_implemented")
let tthird = ("tthird", "not_implemented")

let alt_iszero = ("alt_iszero", "not_implemented")
let alt_pred = ("alt_pred", "not_implemented")



(* 
 * Make sure all your definitions are added to this -- this is what I'll be testing 
 * 
 *)

let q2_defs : (string * string) list = 
   default_defs @ [ ("alt_0","<x -> x>");
		    ("alt_1","<x -> x false <x -> x>>");
		    ("alt_2","<x -> x false <x -> x false <x -> x>>>");
		    ("alt_3","<x -> x false <x -> x false <x -> x false <x -> x>>>>");
		    ("alt_succ","<n -> <x -> x false n>>");
		    triple; tfirst; tsecond; tthird; 
                    alt_iszero; alt_pred ]



(*************************************************************
 * Question 3
 *
 *************************************************************)

(*
 * By default, all of these are implemented as identifier "not_implemented"
 * 
 * Just replace that with your own definition
 *
 *)

let empty = ("empty","not_implemented")

let cons = ("cons","not_implemented")

let match_list = ("match_list","not_implemented")

let sum = ("sum","not_implemented")

let map = ("map","not_implemented")

let q3_defs : (string * string) list = 
  default_defs @ [empty; cons; match_list; sum; map]

