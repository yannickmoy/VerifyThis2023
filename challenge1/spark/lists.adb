pragma Unevaluated_Use_Of_Old (Allow);

package body Lists is

   procedure Reverse_List (L : in out List_Acc) is
      R : List_Acc := null;
      M : Sequence := Model (L) with Ghost;
   begin
      while L /= null loop

         pragma Loop_Variant (Decreases => Last (Model (L)));
         pragma Loop_Invariant (Model (R).Length + Model (L).Length = M.Length);
         pragma Loop_Invariant
           (for all J in Interval'(1,Last (Model (R))) =>
              Model (R).Get (J) = M.Get (Last (Model (R)) - J + 1));
         pragma Loop_Invariant
           (for all J in Interval'(1,Last (Model (L))) =>
              Model (L).Get (J) = M.Get (Last (Model (R)) + J));

         declare
            Tmp : List_Acc := L;
         begin
            L := Tmp.Next;
            Tmp.Next := R;
            R := Tmp;
         end;

         pragma Assert
           (for all J in Interval'(1,Last (Model (R))) =>
              Model (R).Get (J) = M.Get (Last (Model (R)) - J + 1));
      end loop;

      L := R;
   end Reverse_List;

end Lists;
