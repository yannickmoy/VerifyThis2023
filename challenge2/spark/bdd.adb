package body BDD is

   procedure Eq_Reflexive (N : Node_Acc) is
   begin
      if N.Kind = Node_Var then
         Eq_Reflexive (N.Left);
         Eq_Reflexive (N.Right);
      end if;
   end Eq_Reflexive;

   procedure Eq_Symmetric (N, M : Node_Acc) is
   begin
      if N.Kind = Node_Var then
         Eq_Symmetric (N.Left, M.Left);
         Eq_Symmetric (N.Right, M.Right);
      end if;
   end Eq_Symmetric;

   procedure Eq_Transitive (N, M, P : Node_Acc) is
   begin
      if N.Kind = Node_Var then
         Eq_Transitive (N.Left, M.Left, P.Left);
         Eq_Transitive (N.Right, M.Right, P.Right);
      end if;
   end Eq_Transitive;

   procedure Mk_Node (B : in out Bdd; N : in out Node_Acc) is
      C : constant Cursor := B.Find (N);
   begin
      if B.Has_Element (C) then
         N := B.Element (C);
      else
         B.Include (N);
      end if;
   end Mk_Node;

   procedure Mk_True (B : in out Bdd; N : out Node_Acc) is
   begin
      N := New_Node (Node'(Kind => Node_True));
      Mk_Node (B, N);
   end Mk_True;

   procedure Mk_False (B : in out Bdd; N : out Node_Acc) is
   begin
      N := New_Node (Node'(Kind => Node_False));
      Mk_Node (B, N);
   end Mk_False;

   procedure Mk_If
     (B           : in out Bdd;
      Var         : Variable;
      Left, Right : Node_Acc;
      N           : out Node_Acc)
   is
   begin
      if Left = Right then
         N := Left;
      else
         N := New_Node (Node'(Kind  => Node_Var,
                              Var   => Var,
                              Left  => Left,
                              Right => Right));
         Mk_Node (B, N);
      end if;
   end Mk_If;

   procedure Mk_Var
     (B   : in out Bdd;
      Var : Variable;
      N   : out Node_Acc)
   is
      T : Node_Acc := New_Node (Node'(Kind => Node_True));
      F : Node_Acc := New_Node (Node'(Kind => Node_False));
   begin
      Mk_True (B, T);
      Mk_False (B, F);
      N := New_Node (Node'(Kind  => Node_Var,
                           Var   => Var,
                           Left  => T,
                           Right => F));
      Mk_Node (B, N);
   end Mk_Var;

   procedure Mk_Not
     (B : in out Bdd;
      N : in out Node_Acc)
   is
   begin
      case N.Kind is
         when Node_True =>
            Mk_False (B, N);
         when Node_False =>
            Mk_True (B, N);
         when Node_Var =>
            declare
               T : Node_Acc := N.Left;
               F : Node_Acc := N.Right;
            begin
               Mk_Not (B, T);
               Mk_Not (B, F);
               Mk_If (B, N.Var, T, F, N);
            end;
      end case;
   end Mk_Not;

   procedure Mk_And
     (B    : in out Bdd;
      L, R : Node_Acc;
      N    : out Node_Acc)
   is
   begin
      if L.Kind = Node_True then
         N := R;
      elsif R.Kind = Node_True then
         N := L;
      elsif L.Kind = Node_False or R.Kind = Node_False then
         Mk_False (B, N);
      else
         declare
            T : Node_Acc := New_Node (Node'(Kind => Node_True));
            F : Node_Acc := New_Node (Node'(Kind => Node_False));
         begin
            if L.Var < R.Var then
               Mk_And (B, L.Left, R, T);
               Mk_And (B, L.Right, R, T);
               Mk_If (B, L.Var, T, L, N);
            elsif L.Var = R.Var then
               Mk_And (B, L.Left, R.Left, T);
               Mk_And (B, L.Right, R.Right, T);
               Mk_If (B, L.Var, T, L, N);
            else
               Mk_And (B, L, R.Left, T);
               Mk_And (B, L, R.Right, T);
               Mk_If (B, R.Var, T, L, N);
            end if;
         end;
      end if;
   end Mk_And;

end BDD;
