(* ::Package:: *)

BeginPackage["ForScience`PacletUtils`",{"PacletManager`","JLink`","DocumentationSearch`"}]


(*usage formatting utilities, need to make public before defining, as they're already used in the usage definition*)
<<`FormatUsageCase`;
<<`ParseFormatting`;
<<`MakeUsageString`;
<<`FormatUsage`;
<<`Usage`;

<<`ProcessFile`;
<<`BuildPaclet`;
<<`BuildAction`;
<<`CompatibilityChecker`;
<<`VariableLeakTracer`;
<<`UsageCompiler`;
<<`DocUtils`;
<<`DocumentationCache`;
<<`DocumentationHeader`;
<<`DocumentationFooter`;
<<`IndexDocumentation`;
<<`DocumentationSummary`;
<<`DocumentationBuilder`;
<<`UsageSection`;
<<`Details`;
<<`Examples`;
<<`SeeAlso`;


FormatUsageCase::usage=FormatUsage@"FormatUsageCase[str] prepares all function calls wrapped in '''[\[InvisibleSpace][''' and ''']\[InvisibleSpace]]''' in ```str``` to be formatted nicely by '''ParseFormatting'''. See also '''FormatUsage'''. Specifying StartOfLine->True automatically detects usages at the beginning of lines.";
ParseFormatting::usage=FormatUsage@"ParseFormatting[str] formats" <> " anything wrapped in \!\(\*StyleBox[\"```\",\"MR\"]\) as 'Times Italic' and anything wrapped in  \!\(\*StyleBox[\"'''\",\"MR\"]\) as 'Mono Regular'." <> FormatUsage@" Also formats subscripts to a_b (written as " <> "\!\(\*StyleBox[\"a_b\",\"MR\"]\) or \!\(\*StyleBox[\"{*a}}_{*b*}\",\"MR\"]\)). Returns  a box expression." <> FormatUsage@" Use [*MakeUsageString*] to convert to a string.";
MakeUsageString::usage=FormatUsage@"MakeUsageString[str] converts the box expression returned by [*ParseFormatting*] to a string that can be used as usage message.";
FormatUsage::usage=FormatUsage@"FormatUsage[str] combines the functionalities of '''FormatUsageCase''', '''ParseFormatting''' and '''MakeUsageString'''.";
Usage::usage=FormatUsage@"Usage[sym]'''=```usage```''' sets the usage message of ```sym``` to [*FormatUsage[sym]*]. If set, a usage section is generated by [*DocumentBuilder*].";


EndPackage[]
