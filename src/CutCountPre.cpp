#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <sstream>
#include <algorithm>
#include <vector>
#include <stdlib.h>
#include "CutCountPre.h"
using namespace std;

CutCountPre::CutCountPre(string readsIfile, string readsOpath)
{
  this -> readsIfile = readsIfile;
  this -> readsOpath = readsOpath;
}


int CutCountPre::EXCutCount()
{
  // input bed file
  string ipath = this -> readsIfile;
  // output path + prefix
  string opath = this -> readsOpath;

  ifstream readsifile(ipath.c_str(), ios::in);

  // vector to save cut site
  vector<int> cutsite;

  // parameters used in this program
  int MAX_LINE_LENGTH = 100000;
  char line[MAX_LINE_LENGTH] = {0};
  const char *sep = "\t ";

  // initialization
  if(!readsifile.getline(line, sizeof(line)))
  {
    cout << "ERROR: the input file is empty!" <<endl;
    return 0;
  }
  string chr(strtok(line, sep));
  int start = atoi(strtok(NULL, sep));
  int end = atoi(strtok(NULL, sep));
  string chr_flag;
  chr_flag = chr;
  string outputfile = opath + chr + ".bed";
  cutsite.push_back(start);
  cutsite.push_back(end);

  while(readsifile.getline(line, sizeof(line)))
  {
    chr = strtok(line, sep);
    start = atoi(strtok(NULL, sep));
    end = atoi(strtok(NULL, sep));
    if(chr == chr_flag)
    {
      cutsite.push_back(start);
      cutsite.push_back(end);
    }
    else
    {
      //cout << outputfile << endl;
      //********************write data to the output file********************
      ofstream readsofile(outputfile.c_str(), ios::out);
      sort(cutsite.begin(), cutsite.end());
      for(int i = 0; i < cutsite.size(); i++)
      {
        readsofile << cutsite[i] << "\n";
      }
      readsofile.close();
      cutsite.clear();
      //*********************************************************************
      chr_flag = chr;
      outputfile = opath + chr_flag + ".bed";
      cutsite.push_back(start);
      cutsite.push_back(end);
    }
  }

  //cout << outputfile << endl;
  //********************write the last chromatin data to the output file********************
  ofstream readsofile(outputfile.c_str(), ios::out);
  sort(cutsite.begin(), cutsite.end());
  for(int i = 0; i < cutsite.size(); i++)
  {
    readsofile << cutsite[i] << "\n";
  }
  readsofile.close();
  //****************************************************************************************

  readsifile.close();
  return 0;
}