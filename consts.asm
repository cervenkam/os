;nasleduji definice segmentu a jejich velikosti (v sektorech po 512bajtech), lze menit jen velikosti
%define segment_jadra 0x1000
%define velikost_jadro 9
%define segment_filesystem 0x2000
%define velikost_filesystem 1
%define segment_editor 0x3000
%define velikost_editor 1
%define segment_prohlizec 0x4000
%define velikost_prohlizec 1
%define segment_obrazky 0x9000
%define velikost_obrazky 15

;nemenit nasledujici definice:
%define start_jadro 2
%define start_filesystem (start_jadro+velikost_jadro)
%define start_editor (start_filesystem+velikost_filesystem)
%define start_prohlizec (start_editor+velikost_editor)
%define start_obrazky (start_prohlizec+velikost_prohlizec)
%define jadro start_jadro*256+velikost_jadro
%define filesystem start_filesystem*256+velikost_filesystem
%define editor start_editor*256+velikost_editor
%define prohlizec start_prohlizec*256+velikost_prohlizec
%define obrazky start_obrazky*256+velikost_obrazky

;pevne adresy v cizich segmentech
%define text_nastavit_video_mod 0x9000:0x0000
%define text_zobrazit 0x9000:0x0040
