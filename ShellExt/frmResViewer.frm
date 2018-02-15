VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{9A143468-B450-48DD-930D-925078198E4D}#1.1#0"; "hexed.ocx"
Begin VB.Form frmResViewer 
   Caption         =   "Resource Viewer"
   ClientHeight    =   7155
   ClientLeft      =   165
   ClientTop       =   735
   ClientWidth     =   14910
   LinkTopic       =   "Form1"
   ScaleHeight     =   7155
   ScaleWidth      =   14910
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtReport 
      Height          =   1815
      Left            =   60
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   2
      Top             =   5160
      Width           =   3495
   End
   Begin rhexed.HexEd he 
      Height          =   6855
      Left            =   3600
      TabIndex        =   1
      Top             =   120
      Width           =   11175
      _ExtentX        =   19711
      _ExtentY        =   12091
   End
   Begin MSComctlLib.ListView lv 
      Height          =   4935
      Left            =   60
      TabIndex        =   0
      Top             =   120
      Width           =   3435
      _ExtentX        =   6059
      _ExtentY        =   8705
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   2
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Size"
         Object.Width           =   1058
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "Path"
         Object.Width           =   4410
      EndProperty
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "mnuPopup"
      Begin VB.Menu mnuSave 
         Caption         =   "Save"
      End
      Begin VB.Menu mnuSaveAll 
         Caption         =   "Save All"
      End
   End
End
Attribute VB_Name = "frmResViewer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim pe As CPEEditor
Dim selData As CResData

Sub ShowResources(pee As CPEEditor)
    Set pe = pee
    
    Dim r As CResData
    Dim li As ListItem
    
    For Each r In pe.Resources.Entries
        Set li = lv.ListItems.Add(, , r.size)
        Set li.Tag = r
        li.SubItems(1) = r.path
    Next
    
    If lv.ListItems.Count > 0 Then lv_ItemClick lv.ListItems(1)
    
    Me.Show
    SetWindowTopMost Me

End Sub
 
Private Sub Form_Load()
    mnuPopup.Visible = False
End Sub

Private Sub lv_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)
    'LV_ColumnSort lv, ColumnHeader
End Sub

Private Sub lv_ItemClick(ByVal Item As MSComctlLib.ListItem)
    Dim r As CResData
    Dim o As Long
    Dim b() As Byte
    
    Set r = Item.Tag
    Set selData = r
    
    If r.size < 2000000 Then '2mb
        If pe.Resources.GetResourceData(r.path, b) Then
            he.LoadByteArray b
        Else
            he.LoadString "GetResourceData Failed??"
        End If
    Else
        If he.LoadedFile <> pe.LoadedFile Then he.LoadFile pe.LoadedFile
        o = pe.RvaToOffset(r.OffsetToDataRVA)
        he.scrollTo o
        he.SelStart = o
        he.SelLength = r.size - 1
    End If
    
    txtReport = r.report()
    
End Sub

Private Sub lv_MouseUp(Button As Integer, Shift As Integer, x As Single, Y As Single)
    If Button = 2 Then PopupMenu mnuPopup
End Sub

Private Sub mnuSave_Click()
    On Error Resume Next
    Dim pth As String
    
    If selData Is Nothing Then Exit Sub
    
    pth = dlg.SaveDialog(AllFiles, fso.GetParentFolder(pe.LoadedFile), , , , Replace(selData.path, "\", "_") & ".rsc")
    If Len(pth) = 0 Then Exit Sub
    
    If Not pe.Resources.SaveResource(pth, selData.path) Then
        MsgBox "Failed to save resource?"
    End If
        
End Sub

Private Sub mnuSaveAll_Click()
    On Error Resume Next
    Dim pth As String
    Dim r As CResData
    Dim li As ListItem
    Dim e()
    Dim fp As String
    
    If lv.ListItems.Count = 0 Then Exit Sub
    
    pth = dlg.FolderDialog(fso.GetParentFolder(pe.LoadedFile))
    If Len(pth) = 0 Then Exit Sub
    
    For Each li In lv.ListItems
        Set r = li.Tag
        fp = pth & "\" & Replace(r.path, "\", "_") & ".rsc"
        If Not pe.Resources.SaveResource(fp, r.path) Then
            push e, r.path
        End If
    Next
    
    If Not AryIsEmpty(e) Then
        MsgBox "Failed to save the following resources:" & vbCrLf & vbTab & Join(e, vbCrLf & vbTab)
    Else
        MsgBox lv.ListItems.Count & " files saved!"
    End If
    
End Sub
