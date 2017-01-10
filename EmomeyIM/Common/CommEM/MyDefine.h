#define _DATA_Check_				1
#define _DATA_L2LB_User_Login_		30103

#define _DATA_IM_Login_				20001
#define _DATA_IM_Login2_			20701
#define _DATA_IM_NewMsg_			20101
#define _DATA_IM_BC_Msg_			20201
#define _DATA_IM_DelMsg_			20301
#define _DATA_IM_QueryMsg_			20401
#define _DATA_IM_QueryMember_		20501
#define _DATA_IM_ModNickName_		20601
#define _DATA_IM_BulkMsg_			20801
#define _DATA_IM_BC_Cmd_			20901
#define _DATA_IM_ModGrpNickName_	21001
#define _DATA_IM_ModGrpInfo_		21101
#define _DATA_IM_CrtBatGrp_			21201
#define _DATA_IM_ModBatGrp_			21301
#define _DATA_IM_DelBatGrp_			21401
#define _DATA_IM_ModBatGrpName_		21501
#define _DATA_IM_BatGrpMsg_			21601
#define _DATA_IM_QrySvrGrp_			21701
#define _DATA_IM_QryBatGrp_			21801
#define _DATA_IM_BatGrpAddRmv_		21901
#define _DATA_IM_QueryMsgAll_		22001

#define _DATA_IM_Upload_			30101
#define _DATA_IM_Download_			30201

#define MYWM_LOGIN				WM_APP+100
#define MYWM_MESSAGE			WM_APP+101
#define MYWM_HSCROLL			WM_APP+102
#define MYWM_VSCROLL			WM_APP+103

#define MYWM_FORWARD_MSG		WM_APP+104

#define MYWM_SYSTEMTRAY_MSG     WM_APP+105
#define MYWM_LB_LOGIN		    WM_APP+106
#define MYWM_FLASHWINDOW        WM_APP+107


#define MY_QUERY_DATA_IM		            (0x8000 + 3262) 
#define MY_QUERY_DATA_JRPT		            (0x8000 + 3263)  // ºÍIMÍ¨Ñ¶

#define VOICE_BUF_LEN				1024 * 8
enum
{
	JRPT_DATA_QUERY_NAME = 1,
	JRPT_DATA_QUERY_PNG,
	JRPT_START_FLASH_IM_ICON,
	JRPT_STOP_FLASH_IM_ICON
};

enum
{
	Button_Up,
	Button_Over,
	Button_Down
};

#define MAX_FRAME_SIZE 2000
#define MAX_FRAME_BYTES 2000