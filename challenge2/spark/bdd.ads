pragma Unevaluated_Use_Of_Old (Allow);

with SPARK.Big_Integers; use SPARK.Big_Integers;
with SPARK.Containers.Formal.Unbounded_Hashed_Sets;
with Ada.Containers; use Ada.Containers;
with SPARK.Big_Intervals; use SPARK.Big_Intervals;

package BDD is

   type Variable is new Integer;

   type Node;
   type Node_Acc is not null access constant Node;
   type Node_Kind is (Node_Var, Node_False, Node_True);
   type Node (Kind : Node_Kind := Node_False) is record
      case Kind is
         when Node_Var =>
            Var   : Variable;
            Left  : Node_Acc;
            Right : Node_Acc;
         when Node_False
            | Node_True
         =>
            null;
      end case;
   end record;

   function New_Node (N : Node) return Node_Acc is
     (new Node'(N))
   with
     Annotate => (GNATprove, Intentional, "memory leak",
                  "allocation of access-to-constant is not reclaimed");

   function Hash (N : Node_Acc) return Hash_Type is (0);

   function "=" (N, M : Node_Acc) return Boolean is
     (if N.Kind /= M.Kind then False
      elsif N.Kind in Node_False | Node_True then True
      else
        N.Var = M.Var and then
        N.Left.all = M.Left.all and then
        N.Right.all = M.Right.all)
   with
     Subprogram_Variant => (Structural => N);

   procedure Eq_Reflexive (N : Node_Acc)
   with
     Ghost,
     Subprogram_Variant => (Structural => N),
     Post => N = N;

   procedure Eq_Symmetric (N, M : Node_Acc)
   with
     Ghost,
     Subprogram_Variant => (Structural => N),
     Pre  => N = M,
     Post => M = N;

   procedure Eq_Transitive (N, M, P : Node_Acc)
   with
     Ghost,
     Subprogram_Variant => (Structural => N),
     Pre  => N = M and M = P,
     Post => M = P;

   package Sets is new SPARK.Containers.Formal.Unbounded_Hashed_Sets
     (Node_Acc,
      Hash,
      Eq_Reflexive => Eq_Reflexive,
      Eq_Symmetric => Eq_Symmetric,
      Eq_Transitive => Eq_Transitive,
      Equivalent_Elements_Symmetric => Eq_Symmetric,
      Equivalent_Elements_Transitive => Eq_Transitive);
   use Sets;

   subtype Bdd is Set;

   procedure Mk_Node (B : in out Bdd; N : in out Node_Acc)
   with
     Pre => B.Length < Count_Type'Last;

   procedure Mk_True (B : in out Bdd; N : out Node_Acc)
   with
     Pre => B.Length < Count_Type'Last and then not N'Constrained;

   procedure Mk_False (B : in out Bdd; N : out Node_Acc)
   with
     Pre => B.Length < Count_Type'Last and then not N'Constrained;

   procedure Mk_If
     (B           : in out Bdd;
      Var         : Variable;
      Left, Right : Node_Acc;
      N           : out Node_Acc)
   with
     Pre => B.Length < Count_Type'Last and then not N'Constrained;

   procedure Mk_Var
     (B   : in out Bdd;
      Var : Variable;
      N   : out Node_Acc)
   with
     Pre => B.Length < Count_Type'Last and then not N'Constrained;

   procedure Mk_Not
     (B : in out Bdd;
      N : in out Node_Acc)
   with
     Pre => B.Length < Count_Type'Last and then not N'Constrained;

end BDD;
