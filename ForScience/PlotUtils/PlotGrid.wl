(* ::Package:: *)

PlotGrid;


Begin["`Private`"]


ClipFrameLabels[graph_,sides_List]:=
  graph/.g_Graphics:>With[
    {
      drop=Complement[Keys@$SidePositions,sides]/.$SidePositions,
      frame=NormalizedOptionValue[g,Frame]
    },
    Show[
      g,
      FrameLabel->ReplacePart[
        NormalizedOptionValue[g,FrameLabel],
        drop->None
      ],
      FrameTicksStyle->MapIndexed[
        Which[
          !Extract[frame,#2],
          None,
          MemberQ[drop,#2],
          Directive[FontSize->0,FontOpacity->0,#],
          True,
          #
        ]&,
        NormalizedOptionValue[g,FrameTicksStyle],
        {2}
      ]
    ]
  ]


ProcessSymbolicPos[pos_List]:=
  Replace[
    pos,
    {Center->0.5,Except[_?NumericQ]->2},
    1
  ]
ProcessSymbolicPos[pos_]:=
  ProcessSymbolicPos@{pos,pos}


LegendInsideQ[
  Placed[
    _,
    (pos:Center|{Center,Center})|
      Scaled[pos_]|
      {
        Scaled[pos_]|
          pos:Center|{Center,Center},
        _List|_Scaled|_ImageScaled
      },
    ___
  ]
]:=
  AllTrue[Between@{0,1}]@ProcessSymbolicPos@pos
LegendInsideQ[_]:=False


ExpandFrameLabelSpec[{def:Except[_Rule]:Automatic,rules___Rule}]:=
  #->Lookup[<|rules|>,#,def]&/@{Left,Right,Bottom,Top}
ExpandFrameLabelSpec[s:Automatic|Full|True|False|All|None]:=
  ExpandFrameLabelSpec[{s}/.{All->True,None->False}]
ExpandFrameLabelSpec[{h_,v_}]:=
  {Left->v,Right->v,Bottom->h,Top->h}
ExpandFrameLabelSpec[{{l_,r_},{b_,t_}}]:=
  {Left->l,Right->r,Bottom->b,Top->t}


ReverseY[{x_,y_}]:=
  {x,Reverse@y}


AccumulateShifts[vals_,shifts_]:=
  ReverseY[
    FoldList[Plus,0,#]&/@(Most/@ReverseY@vals+ReverseY@shifts)
  ]


XYLookup[{i_,j_}][{x_,y_}]:=
  {x[[j]],y[[i]]}


ApplyShowFrameLabels[{i_,j_},gr_,setting_,grid_,spacings_]:=
  With[
    {
      plotsPresent=ListLookup[grid,{i,j}+#/.(0->Null),Null]=!=Null&/@
        <|Left->{0,-1},Right->{0,1},Bottom->{1,0},Top->{-1,0}|>,
      spacingsPresent=ListLookup[spacings,#/.(0->Null),1]=!=0&/@
        <|Left->{1,j-1},Right->{1,j},Bottom->{2,i},Top->{2,i-1}|>
    },
    ClipFrameLabels[
      gr,
      If[
        #2/.{
          Automatic->!plotsPresent[#],
          Full->!plotsPresent[#]||spacingsPresent[#]
        },
        #,
        Nothing
      ]&@@@setting
    ]
  ]


PlotGrid::noScaled="Invalid item size spec ``. At least one column/row dimension must be relative.";


Options[PlotGrid]={FrameStyle->Automatic,ItemSize->Automatic,Spacings->None,"ShowFrameLabels"->Automatic};


PlotGrid[
  l_?(MatrixQ[#,ValidGraphicsQ@#||#===Null&]&),
  o:OptionsPattern[Join[Options[PlotGrid],Options[Graphics]]]
]:=
  Module[
    {
      nx,ny,
      plots,
      padding,
      frameStyle,
      frameGraphics,
      frameInset=Nothing,
      framePadding=0,
      gi,
      grid,
      legends,
      sizes,
      rangeSizes,
      imageSizes,
      rawSpacings,
      spacings,
      positions,
      positionOffsets,
      sizeOffsets,
      showFrameLabels,
      effectiveImagePadding
    },
    {ny,nx}=Dimensions@l;
    rawSpacings=Expand2DSpec[OptionValue[Spacings],{nx-1,ny-1}]/.{None|Automatic->0};
    showFrameLabels=Map[
      ExpandFrameLabelSpec,
      ExpandGridSpec[OptionValue["ShowFrameLabels"],{nx,ny}]/.
        Directive->List,
      {2}
    ];
    plots=Table[
      ApplyShowFrameLabels[
        {i,j},
        l[[i,j]],
        showFrameLabels[[i,j]],
        l,
        rawSpacings
      ],
      {i,ny},
      {j,nx}
    ];
    gi=GraphicsInformation[plots];
    padding=Apply[
      Max[
        Replace[
          gi[ImagePadding][[#,#2]],
          {
            Null->0,
            pad_:>pad[[##3]]
          },
          1
        ],
        1
      ]&,
      {
        {{All,1,1,1},{All,-1,1,-1}},
        {{-1,All,-1,1},{1,All,-1,-1}}
      },
      {2}
    ];
    sizes=Expand2DSpec[OptionValue[ItemSize],{nx,ny}];
    rangeSizes=Map[Mean]/@(
      MapAt[
        Transpose,
        1
      ]@Transpose[
        Apply[
          Abs@*Subtract,
          gi[PlotRange],
          {3}
        ]/.
          Null->{Null,Null},
        {2,3,1}
      ]/.
        Null->Nothing
    );
    imageSizes=Map[Mean]/@(
      MapAt[
        Transpose,
        1
      ]@Transpose[
        gi[ImageSize]/.
          Null->{Null,Null},
        {2,3,1}
      ]/.
        Null->Nothing
    );
    sizeOffsets=Replace[
      sizes,
      {
        Offset[off_,_:0]:>off,
        _->0
      },
      {2}
    ];
    sizes=Replace[
      sizes,
      Offset[_,sz_:0]:>sz,
      {2}
    ];
    If[MemberQ[Total/@sizes,0],
      Message[PlotGrid::noScaled,OptionValue[ItemSize]];
      Return@$Failed
    ];
    sizes=MapThread[
      Replace[
        #,
        {
          Scaled[s_]:>s #3,
          ImageScaled[s_]:>s #4,
          Automatic->1/#2,
          Scaled->#3,
          ImageScaled->#4,
          s_:>s/#2
        }
      ]&,
      #
    ]&/@Transpose@{
        sizes,
        Total@Replace[#,{_[s_]:>s,Automatic->1},1]&/@sizes+0 sizes,
        Normalize[#,Total]&/@rangeSizes,
        Normalize[#,Total]&/@imageSizes
      };
    If[MemberQ[Total/@sizes,0],
      Message[PlotGrid::noScaled,OptionValue[ItemSize]];
      Return@$Failed
    ];
    sizes=Normalize[#,Total]&/@sizes;
    positionOffsets=Replace[
      rawSpacings,
      _Scaled->0,
      {2}
    ];
    spacings=Replace[
      rawSpacings,
      {
        Scaled@s_:>s,
        _->0
      },
      {2}
    ];
    sizeOffsets+=-(Total/@positionOffsets+Total/@sizeOffsets)*sizes;
    sizes*=(1-Total/@spacings);
    positionOffsets=AccumulateShifts[sizeOffsets,positionOffsets];
    positions=AccumulateShifts[sizes,spacings];
    frameStyle=NormalizeGraphicsOpt[FrameStyle]@Replace[
      OptionValue[FrameStyle],
      Automatic->GraphicsOpt[FirstCase[plots,_Graphics,{},All],FrameStyle]
    ];
    If[OptionValue[FrameLabel]=!=None,
      frameGraphics=If[
        #=!=Table[None,2,2],
        Graphics[
          {},
          Frame->True,
          FrameTicks->None,
          FrameStyle->Replace[
            frameStyle,
            None|Directive[d___]|{d___}|d2_:>
              Directive[d,d2,Opacity@0],
            {2}
          ],
          FrameLabel->Replace[
            #,
            lbl:Except[None]:>Style[lbl,Opacity@1],
            {2}
          ],
          AspectRatio->Full,
          ImageSize->Total/@imageSizes
        ],
        Null
      ]&/@(
        {{#,{None,None}},{{None,None},#2}}&@@
          NormalizeGraphicsOpt[FrameLabel]@OptionValue[FrameLabel]
      );
      framePadding=GraphicsInformation[frameGraphics][ImagePadding];
      frameInset=MapThread[
        If[
          #=!=Null,
          Inset[
            #,
            Offset[-#2,Scaled[{0,0}]],
            Scaled[{0,0}],
            Offset[#3,Scaled[{1,1}]]
          ],
          Nothing
        ]&,
        {
          frameGraphics,
          DiagonalMatrix@padding[[All,1]],
          IdentityMatrix[2](Total/@(padding+#)&/@framePadding)
        }
      ];
      framePadding=Extract[framePadding/.Null->Table[0,2,2],{{1,1},{2,2}}]
    ];
    {plots,legends}=Reap@Map[
      If[#=!=Null,
        ApplyToWrapped[
          (Sow@#2;#)&,
          #,
          _Graphics,
          Legended[_,Except@_?LegendInsideQ],
          Method->Function
        ]
      ]&,
      plots,
      {2}
    ];
    grid=Graphics[
      {
        Table[
          If[plots[[i,j]]=!=Null,
            With[
              {xyLookup=XYLookup[{i,j}]},
              Inset[
                Show[
                  plots[[i,j]],
                  ImagePadding->gi[ImagePadding][[i,j]],
                  AspectRatio->Full
                ],
                Offset[
                  xyLookup@positionOffsets,
                  xyLookup@positions
                ],
                Scaled[{0,0}],
                Offset[
                  Total/@gi[ImagePadding][[i,j]]+xyLookup@sizeOffsets,
                  Scaled@xyLookup@sizes
                ]
              ]
            ],
            Nothing
          ],
          {i,ny},
          {j,nx}
        ],
        frameInset
      },
      PlotRange->{{0,1},{0,1}},
      AspectRatio->Replace[
        OptionValue[AspectRatio],
        Automatic->ny/nx/GeometricMean[Divide@@@DeleteCases[Null]@Flatten[gi["PlotRangeSize"],1]]
      ],
      FilterRules[
        FilterRules[{o},Options@Graphics],
        Except[FrameLabel]
      ],
      ImagePadding->padding+framePadding   
    ];
    effectiveImagePadding=GraphicsOpt[grid,ImagePadding];
    If[!MatchQ[effectiveImagePadding,{{_?NumericQ,_?NumericQ},{_?NumericQ,_?NumericQ}}],
      effectiveImagePadding=GraphicsInformation[grid][ImagePadding]
    ];
    grid=Show[
      grid,
      CoordinatesToolOptions->With[
        {
          ny=ny,
          positions=positions,
          imagePadding=First/@effectiveImagePadding,
          positionOffsets=positionOffsets,
          sizes=sizes,
          sizeOffsets=sizeOffsets,
          plotRanges=gi[PlotRange],
          df=Map[If[#=!=Null,GetCoordinatesToolOptions[#]@"DisplayFunction"]&,plots,{2}],
          cvf=Map[If[#=!=Null,GetCoordinatesToolOptions[#]@"CopiedValueFunction"]&,plots,{2}]
        },
        Function[
          {type,funcs,valFunc,def},
          type->(With[
            {
              absPos=MousePosition["GraphicsAbsolute"]-imagePadding
            },
            With[
              {
                plotData=MapAt[Reverse,2]@Transpose@MapThread[
                  List@@First[
                    Normal@Map[First]@
                      KeySelect[Apply@Between]@
                        PositionIndex[
                          Thread@{#,Thread@{#2,#2+#3}}
                        ],
                    {0,0}
                  ]&,
                  {
                    #*absPos,
                    positions*absPos+positionOffsets*#,
                    sizes*absPos+sizeOffsets*#
                  }
                ]
              },
              With[
                {
                  id=Last@plotData
                },
                If[FreeQ[id,0]&&Extract[plotRanges,id]=!=Null,
                  valFunc[
                    id,
                    If[#=!=None,#,Nothing&]&[
                      Extract[funcs,id]
                    ]@MapThread[
                        Rescale,
                        {
                          plotData[[1,All,1]],
                          plotData[[1,All,2]],
                          Extract[plotRanges,id]
                        }
                      ]
                  ],
                  def
                ]
              ]
            ]
          ]&)
        ]@@@{
          {"DisplayFunction",df,Column@{Row@{"Plot: ",#},#2}&,"Not inside a plot"},
          {"CopiedValueFunction",cvf,List,Missing["OutsidePlot"]}
        }
      ]
    ];
    (RightComposition@@Flatten@legends)@grid
  ]


End[]
