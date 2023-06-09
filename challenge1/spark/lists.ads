-- Only handle the case of null-terminated finite lists, which corresponds to
-- the only List objects that the ownership rules of SPARK allow to build.

pragma Unevaluated_Use_Of_Old (Allow);

with SPARK.Big_Integers; use SPARK.Big_Integers;
with SPARK.Containers.Functional.Infinite_Sequences;
with SPARK.Big_Intervals; use SPARK.Big_Intervals;

package Lists is

   type List;
   type List_Acc is access List;
   type List is record
      Value : Integer;
      Next : List_Acc;
   end record;

   package LLists is new SPARK.Containers.Functional.Infinite_Sequences (Integer);
   use LLists;

   function Model (L : access constant List) return Sequence is
     (if L = null then Empty_Sequence
      else Add (Model (L.Next), Position => 1, New_Item => L.Value))
   with
      Subprogram_Variant => (Structural => L);

   procedure Reverse_List (L : in out List_Acc)
   with
     Annotate => (GNATprove, Always_Return),
     Post =>
       Model (L).Last = Model (L)'Old.Last and then
       (for all J in Interval'(1, Model (L).Last) =>
          Model (L).Get (J) = Model (L)'Old.Get (Model (L).Last - J + 1));

end Lists;
