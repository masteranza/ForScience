(* ::Package:: *)

Usage[ParseFormatting]="ParseFormatting[str] returns a box expression formatted according to the format specification of ```str```.";


Begin[BuildAction]


DocumentationHeader[ParseFormatting]=FSHeader["0.50.0","0.87.18"];


Details[ParseFormatting]={
  "[*ParseFormatting*] returns a box expression.",
  "The returned box expression can be converted to a string using [*MakeUsageString*].",
  "For supported format specifications, see [*FormatUsage*].",
  "[*ParseFormatting*] is called as part of [*FormatUsage*].",
  "Under normal circumstances, [*ParseFormatting*] should not need to be used directly."
};


SeeAlso[ParseFormatting]={Usage,MakeUsageString,FormatUsage};


Guides[ParseFormatting]={$GuideCreatingDocPages};


End[]
