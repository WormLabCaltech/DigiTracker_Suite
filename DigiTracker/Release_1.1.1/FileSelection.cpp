// FileSelection.cpp : implementation file
//

#include "stdafx.h"
#include "FileSelection.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// FileSelection dialog

FILE * filepath;         // default record pathname file descriptor
FILE * outfile;         // record file descriptor 
char path_string [128]; // record pathname file

FileSelection::FileSelection(CWnd* pParent /*=NULL*/)
	: CDialog(FileSelection::IDD, pParent)
{
	//{{AFX_DATA_INIT(FileSelection)
	m_file_path_name = _T("");
	//}}AFX_DATA_INIT
}


void FileSelection::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(FileSelection)
	DDX_Control(pDX, IDC_CHECK1, m_save_as_default);
	DDX_Text(pDX, IDC_EDIT1, m_file_path_name);
	DDV_MaxChars(pDX, m_file_path_name, 128);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(FileSelection, CDialog)
	//{{AFX_MSG_MAP(FileSelection)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// FileSelection message handlers

void FileSelection::OnCancel() 
{
	// TODO: Add extra cleanup here
	
	CDialog::EndDialog(IDCANCEL);
}

void FileSelection::OnOK() 
{
    DeviceNotReady devicenotready;
	No_Source_Dir nosourcedir;
	FileNotSelection filenotselection;
    DirCreateError dircreateerror;
    #define MAX_DEPTH 20

    int i,j=0, last_slash,path_length,number_of_slashes=0,status=IDOK;
	int save_it = m_save_as_default.GetCheck();
	int device;
	TCHAR path_char, pathchar[128]={NULL},pending_message[128]={NULL};
	char local_out_name[128]={NULL}, local_directory[128]={NULL};
	char local_filename[128]={NULL};
	char subdirectory[MAX_DEPTH] [128] = {{NULL},{NULL},{NULL},{NULL},{NULL},
										{NULL},{NULL},{NULL},{NULL},{NULL}};
	int subdir_length[MAX_DEPTH] = {0};

	CDialog::OnOK();
    path_length = m_file_path_name.GetLength();
	
	// parse the path / filename selected for output frames
   for (i = 0; i < path_length;i++)
	{
	 path_char = m_file_path_name.GetAt(i);
	 if (path_char == '\\') 
	 {
	  if (!number_of_slashes)
	  {
		strcat(subdirectory[number_of_slashes],"\\\\");
		j+=2;
	  }
	  subdir_length[number_of_slashes]= j;
 	  last_slash = i+1;
	  number_of_slashes++;
	  j = 0;
	 }
	 pathchar[i] = path_char;
     if (path_char != '\\')
		 subdirectory[number_of_slashes][j++]=path_char;
   }
    
 	if (save_it)
	{
	 filepath= fopen(path_string,"w");
	 fwrite(pathchar, sizeof (char), last_slash,filepath);
	 fclose(filepath);
	}

	GetCurrentDirectory(sizeof(local_directory),local_directory);

	// make sure selected device is available
	device = (toupper(pathchar[0]) - 'A')+1;
	if (_chdrive(device))
	{
		 
		sprintf (pending_message,"Selected Device %c: not ready!",pathchar[0]);
        devicenotready.m_device_not_ready = pending_message;
		status = IDRETRY;
		while (status==IDRETRY) {
			status = devicenotready.DoModal();
			if (!_chdrive(device))
				status = IDOK;
		}
		if (status == IDCANCEL) {
		  CDialog::EndDialog(IDRETRY);
		  return;
		}
	}

	for (i = 0; number_of_slashes > i && i < MAX_DEPTH; i++)
	{
	 if (_chdir (subdirectory[i]))
	 {
	  memset(pending_message,' ',sizeof(pending_message));
	  sprintf (pending_message, "Selected subdirectory: %s does not exist!",subdirectory[i]);
      nosourcedir.m_no_directory = pending_message;

      if (nosourcedir.DoModal() == IDYES)
	  {
		 if (!_mkdir(subdirectory[i]))
		 {
		   _chdir(subdirectory[i]);
		 }
         else
		 {
		   memset(pending_message,' ',sizeof(pending_message));
	       sprintf(pending_message,"Could not create subdirectory:\n %s",subdirectory[i]);
           dircreateerror.m_dir_fail = pending_message;
		   status = DoModal();
		   CDialog::EndDialog(status);
		   return;
		 }
	  }
	  else
	  {
		  CDialog::EndDialog(IDRETRY);
		  return;
      }
	 }
	}
   

	 outfile = fopen(subdirectory[number_of_slashes],"w");
	 if (!outfile)
	 {
       memset(pending_message,' ',sizeof(pending_message));
	   sprintf(pending_message,"Could not open requested file: %s",
		       subdirectory[number_of_slashes]);
       filenotselection.m_file_nogo = pending_message;
       filenotselection.DoModal();
	   status = IDRETRY;
	 }
	// test stuff
    memset(pathchar,' ',sizeof(pathchar));
	sprintf (pathchar,"this is a test file\n");
	fwrite (pathchar, sizeof (char), sizeof(pathchar),outfile);
	fclose(outfile);
      
	
	CDialog::EndDialog(status);
}

////////////////////////////////////////////////////////
bool set_record_file(SYSTEMTIME *current_time)
{
  bool return_status = FALSE;
  char outfile[128];
  int  path_size,display_status;
  TCHAR full_name[128];
  FileSelection fileselection;


  sprintf (path_string, "record_file_path.dat");
   
   if (filepath=fopen(path_string,"r"))
   {
	  path_size = fread(outfile,sizeof(char),128,filepath);
      strncpy(full_name, outfile,path_size);
      memset(outfile,' ',sizeof(outfile));
	  sprintf(outfile,"%04d_%02d_%02d_%02d_%02d_%02d", 
		  current_time->wYear,current_time->wMonth,current_time->wDay,
		  current_time->wHour,current_time->wMinute,current_time->wSecond);
	  sprintf(full_name+path_size,"%19s.dat",outfile);
      // strncat(full_name,outfile,24);
	  fileselection.m_file_path_name = full_name;
	  fclose(filepath);
   }
   display_status = IDRETRY;
   while (display_status == IDRETRY)
   {
     display_status = fileselection.DoModal();
   }

   if (display_status==IDOK)
   {
	   return_status = TRUE;
   }
   else
   {
      return_status = FALSE;
   }

   return (return_status);
}

void close_record_file()
{
  fclose(outfile);

}

int get_available_space(void)
{
 //return(DISKSPACE());
	return(0);
}
/////////////////////////////////////////////////////////////////////////////
// DeviceNotReady dialog


DeviceNotReady::DeviceNotReady(CWnd* pParent /*=NULL*/)
	: CDialog(DeviceNotReady::IDD, pParent)
{
	//{{AFX_DATA_INIT(DeviceNotReady)
	m_device_not_ready = _T("");
	//}}AFX_DATA_INIT
}


void DeviceNotReady::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(DeviceNotReady)
	DDX_Text(pDX, IDC_NODEVICE, m_device_not_ready);
	DDV_MaxChars(pDX, m_device_not_ready, 128);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(DeviceNotReady, CDialog)
	//{{AFX_MSG_MAP(DeviceNotReady)
	ON_BN_CLICKED(IDRETRY, OnRetry)
	ON_BN_CLICKED(IDQUIT, OnQuit)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// DeviceNotReady message handlers

void DeviceNotReady::OnRetry() 
{
	// TODO: Add your control notification handler code here
	CDialog::EndDialog(IDRETRY);
}

void DeviceNotReady::OnQuit() 
{
	// TODO: Add your control notification handler code here
	CDialog::EndDialog(IDCANCEL);
}
/////////////////////////////////////////////////////////////////////////////
// No_Source_Dir dialog


No_Source_Dir::No_Source_Dir(CWnd* pParent /*=NULL*/)
	: CDialog(No_Source_Dir::IDD, pParent)
{
	//{{AFX_DATA_INIT(No_Source_Dir)
	m_no_directory = _T("");
	//}}AFX_DATA_INIT
}


void No_Source_Dir::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(No_Source_Dir)
	DDX_Text(pDX, IDC_NODIRECTORY, m_no_directory);
	DDV_MaxChars(pDX, m_no_directory, 128);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(No_Source_Dir, CDialog)
	//{{AFX_MSG_MAP(No_Source_Dir)
	ON_BN_CLICKED(IDCREATEDIR, OnCreatedir)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// No_Source_Dir message handlers

void No_Source_Dir::OnCancel() 
{
	// TODO: Add extra cleanup here
	
	// CDialog::OnCancel();
	CDialog::EndDialog(IDCANCEL);
}

void No_Source_Dir::OnCreatedir() 
{
	// TODO: Add your control notification handler code here
	CDialog::EndDialog(IDYES);
}
/////////////////////////////////////////////////////////////////////////////
// FileNotSelection dialog


FileNotSelection::FileNotSelection(CWnd* pParent /*=NULL*/)
	: CDialog(FileNotSelection::IDD, pParent)
{
	//{{AFX_DATA_INIT(FileNotSelection)
	m_file_nogo = _T("");
	//}}AFX_DATA_INIT
}


void FileNotSelection::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(FileNotSelection)
	DDX_Text(pDX, IDC_FILENOGO, m_file_nogo);
	DDV_MaxChars(pDX, m_file_nogo, 128);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(FileNotSelection, CDialog)
	//{{AFX_MSG_MAP(FileNotSelection)
	ON_BN_CLICKED(IDFILENOTOK, OnFilenotok)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// FileNotSelection message handlers

void FileNotSelection::OnFilenotok() 
{
	// TODO: Add your control notification handler code here
	CDialog::EndDialog(IDOK);	
}
/////////////////////////////////////////////////////////////////////////////
// DirCreateError dialog


DirCreateError::DirCreateError(CWnd* pParent /*=NULL*/)
	: CDialog(DirCreateError::IDD, pParent)
{
	//{{AFX_DATA_INIT(DirCreateError)
	m_dir_fail = _T("");
	//}}AFX_DATA_INIT
}


void DirCreateError::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(DirCreateError)
	DDX_Text(pDX, IDC_DIRNOGO, m_dir_fail);
	DDV_MaxChars(pDX, m_dir_fail, 128);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(DirCreateError, CDialog)
	//{{AFX_MSG_MAP(DirCreateError)
	ON_BN_CLICKED(IDOK, OnNoDirOK)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// DirCreateError message handlers



void DirCreateError::OnNoDirOK() 
{
	// TODO: Add your control notification handler code here
	CDialog::EndDialog(IDRETRY);	
}
