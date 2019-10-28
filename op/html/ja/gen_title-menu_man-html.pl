#!C:/Perl/bin/perl.exe
#!/usr/bin/env perl

use strict;

#use encoding 'cp932';
#use open OUT => ":utf8"; # 顕にwrite openしたファイルへの出力はUTF8とする
#binmode STDOUT, ':encoding(shift-jis)';
#binmode STDERR, ':encoding(shift-jis)';

use Data::Dumper;
#{
#  package Data::Dumper;
#  sub qquote {return shift;}
#}
#$Data::Dumper::Useperl = 1;


=head1 名前

gen_title-menu_man-html.pl - title.htmlとmenu_man.htmlの生成

=head1 概要

光トポグラフィ解析ソフトのオンラインマニュアルのhtmlファイルのうち
PDFファイルへのリンクを含むtitle.htmlとツリーメニューのための
menu_man.htmlに差し込むリンクを自動生成し、
それぞれのhtmlファイルをカレントディレクトリに出力する。

このscriptを実行するためにはWindowsにperl処理系がインストールされている必要がある。
動作確認を行ったperl処理系はActiveStateのActivePerl 5.12.2である。

=head1 説明

PDFファイルはこのscriptを実行する前に同じディレクトリに格納しておく。

scriptの実行はWindowsからscriptファイルをダブルクリック、またはコンソールから
perl処理系でscriptを実行する。

出力されるhtmlと同じ名前のファイルがカレントディレクトリにあった場合には
htmlファイル名にサフィックス.bakを付けて保存する。

チャプター番号およびセクション番号とPDFファイルへのリンクの対応は、
このscriptの末尾の__DATA__セクションに
チャプター番号、セクション番号、タイトル、パスをタブで区切って記述する。
パスが省略されている場合、リンクのアンカーが省略され、章タイトルの文字列のみが表示される。

パスが記述されいるが、そのパスのPDFファイルが存在しない場合は、
コンソールにワーニングが出力され、この場合もリンクのアンカーが省略される。
ダブルクリックでscriptを実行した場合は、ワーニングが一瞬だけ表示される。

なお、セクション番号0はチャプターを表す。
また、セクションをひとつも持たないチャプターだけの章のPDFも取り扱える。

=back

=cut

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# データ読込 (章立て/ ページ情報)
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
my %index;
my ($chapt, $sect, $title, $path, $page);
for (<DATA>) {
  chomp;
  ($chapt, $sect, $title, $path, $page) = (split('\t'))[0,1,2,3,4];
  $title =~ s/ /\&nbsp;/g;
  $index{$chapt}{$sect} = {title => $title, path => $path, page => $page};
  ($path and ! -f $path) and
    warn "Warning: file `$path' not found: $!\n"
}

#print Dumper \%index;


use CGI qw/-no_xhtml/;
my $q = new CGI;
### $q->charset('utf-8');


# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
### title.html ###
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
my $file = 'title.html';
rename $file, "./back/${file}.bak"; # backup original file

open(TITLE, "> $file")
  or die "Couldn't open `$file' for writing:";

# --------------------------------------
# ファイル (TITLE) に ヘッダ書き出し
# --------------------------------------
#print TITLE $q->header; # not output HTTP responce header

print TITLE $q->start_html(-title => 'Platform for Optical Topography Analysis Tools',
			   -lang => 'ja',
			   -head => [$q->meta({-http_equiv => 'Content-Type',
					       -content    => 'text/html; charset=Shift_JIS'}),
				     '<base target="main">'],
			   -style => {-src => './matlab_like.css'},
			   -script => {-type => 'JavaScript', -src => './changeScript.js'}
			  );

# --------------------------------------
# タイトル部分書き出し
# --------------------------------------
print TITLE $q->start_table({border=>0, width=>"100%", cellspacing=>"0"}), "\n";
#print TITLE $q->start_table({border=>0,  cellspacing=>"0"}), "\n";
print TITLE <<END;
  <!-- Title -->
  <tr class="mattitle"><td colspan="2">
    <h1 class="mattitle">
      Platform for Optical Topography Analysis Tools
    </h1>
  </td></tr>
  <!-- Link -->
  <tr class="section_lk"><td width="4%"></td><td>
END

# --------------------------------------
# 章 & Link 部分書き出し
# --------------------------------------
for $chapt (sort {$a <=> $b} keys %index) {
  my $chapter = $index{$chapt}{0};
  print TITLE "    ";
  if ($chapter->{path} and -f $chapter->{path}) {
    #print TITLE $q->a({href=>"$chapter->{path}"}, "$chapt.&nbsp;$chapter->{title}")
    print TITLE $q->a({href=>"$chapter->{path}"}, "$chapter->{title}")
  } else {
    #print TITLE "$chapt.&nbsp;$chapter->{title}"
    print TITLE "$chapter->{title}"    
  }
  print TITLE "&nbsp;&nbsp;\n"
}

print TITLE <<END;
  </td></tr>
END
print TITLE $q->end_table;

print TITLE $q->end_html;
close TITLE;

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
### menu-man.html ###
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
my $file = 'menu_man.html';
rename $file, "./back/${file}.bak"; # backup original file

open(MENU_MAN, "> $file")
  or die "Couldn't open `$file' for writing:";

# --------------------------------------
# ファイル (MENU_MAN) に ヘッダ書き出し
# --------------------------------------
#print MENU_MAN $q->header; # not output HTTP responce header

print MENU_MAN <<END;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//JA">
<html lang="ja">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=Shift_JIS">

  <link rel="stylesheet" type="text/css" href="./matlab_like.css">
  <link rel="stylesheet" type="text/css" href="./menu0.css">

  <script type="text/JavaScript" src="./changeScript.js"></script>
  <script type="text/JavaScript" src="./menu.js"></script>
  <title>Platform for Optical Topography Analysis Tools</title>
    
  <base target="main">
</head>
<body style="margin-top:0;padding-top:0;">
<!--  Title -->
<table class="nonespace" border=0 cellspacing="0" cellpadding="0" style="height:100%;">
  <tr><td class="mattitle_">&nbsp;</td><td class="menusize">
  <br><br>
  <ul class="listnone">

END
#<body style="margin:0;padding:0;">

for $chapt (sort {$a <=> $b} keys %index) {
  # --------------------------------------
  # チャプター書き出し
  # --------------------------------------
  my $chapter = $index{$chapt}{0};

  print MENU_MAN <<END;
    <!-- $chapter->{title} -->
    <li id="mancap$chapt" class="mancap">
END

  if ($chapter->{path} and -f $chapter->{path}) {
    # リンク有
    print MENU_MAN <<END;
      <div class="plus"  id="plus$chapt">
         <img src="./plus.gif" alt="+" title=""  onClick="mansecOn($chapt);">
         <a href="$chapter->{path}">
            <span class="menu_chapter">$chapter->{title}</span>
         </a>
      </div>
      <div class="minus"  id="minus$chapt">
         <img src="./minus.gif" alt="-" title="" onClick="mansecOff($chapt);">
         <a href="$chapter->{path}">
            <span class="menu_chapter">$chapter->{title}</span>
         </a>
      </div>
END
  } else {
    # リンク無
    print MENU_MAN <<END;
      <div class="plus"  id="plus$chapt">
         <img src="./plus.gif" alt="+" title=""  onClick="mansecOn($chapt);">
         <span class="menu_chapter">$chapter->{title}</span>
      </div>
      <div class="minus"  id="minus$chapt">
         <img src="./minus.gif" alt="-" title="" onClick="mansecOff($chapt);">
         <span class="menu_chapter">$chapter->{title}</span>
      </div>
END
  }


  # --------------------------------------
  # open section
  # --------------------------------------
  print MENU_MAN <<END;
      <!-- Section -->
      <div id="mansec$chapt" class="mansec">
END

  # for each section
  my @sects = sort {$a <=> $b} keys %{$index{$chapt}};
  for $sect (@sects) {
    next if $sect == 0; # skip chapter
    my $section = $index{$chapt}{$sect};

    print MENU_MAN "      <ol>\n" if $sect == 1;

    # sections
    if ($section->{path} and -f $section->{path}) {
      if ($section->{page}){
        print MENU_MAN <<END;
          <li><a href="$section->{path}#page=$section->{page}">
            <span class="menu_section">$section->{title}</span>
          </a></li>
END
      } else {
        print MENU_MAN <<END;
          <li><a href="$section->{path}">
             <span class="menu_section">$section->{title}</span>
          </a></li>
END
      }
    } else {
      print MENU_MAN <<END;
        <li><span class="menu_section">$section->{title}</span></li>
END
    }

    print MENU_MAN "      </ol>\n" if $sect == $#sects;
  }

# close section
#if ($sect == $#sects) {
#  print MENU_MAN <<END;
#     </ol>
#END
#}

# close chapter
print MENU_MAN <<END;
      </div><br>
    </li>

END
}

# final
print MENU_MAN <<END;
  </ul>
  </td></tr>
END

print MENU_MAN $q->end_table;

print MENU_MAN $q->end_html;
close MENU_MAN;


__DATA__
1	0	概要	Abstract.pdf
1	1	光トポグラフィとは	Abstract.pdf	2
1	2	POTAToとは	Abstract.pdf	3
1	3	開始方法	Abstract.pdf	5
1	4	解析概要	Abstract.pdf	6
1	5	利用条件	Abstract.pdf	7
2	0	基本操作	BasicOperation.pdf
2	1	解析の流れ	BasicOperation.pdf	3
2	2	POTAToのデータ形式	BasicOperation.pdf	6
2	3	実験データの読込と管理	BasicOperation.pdf	15
2	4	データ選択と検索機能	BasicOperation.pdf	20
2	5	メインウィンドウ メニュー	BasicOperation.pdf	23
3	0	拡張検索	ExSearch.pdf
3	1	操作方法	ExSearch.pdf	2
3	2	検索実施例	ExSearch.pdf	7
4	0	ステップガイド	Step-Guide.pdf
4	1	解析してみよう	Step-Guide.pdf	3
4	2	解析方法の設定	Step-Guide.pdf	10
5	0	Normal-Mode	Normal-Mode.pdf
5	1	概要	Normal-Mode.pdf	2
5	2	単一実験データの解析	Normal-Mode.pdf	5
5	3	複数実験データの解析	Normal-Mode.pdf	7
6	0	Research-Mode	Research-Mode.pdf
6	1	概要	Research-Mode.pdf	3
6	2	解析準備	Research-Mode.pdf	7
6	3	要約統計量の算出	Research-Mode.pdf	21
6	4	統計的検定 	Research-Mode.pdf	28
7	0	位置設定	PositionSetting.pdf
7	1	概要	PositionSetting.pdf	2
7	2	位置情報の設定	PositionSetting.pdf	3
8	0	表示機能	LayoutEditor.pdf
8	1	概要	LayoutEditor.pdf	3
8	2	POTAToの表示機能	LayoutEditor.pdf	5
8	3	Layoutの使い方	LayoutEditor.pdf	7
8	4	表示機能拡張	LayoutEditor.pdf	22
9	0	解析の拡張	RecipeDevelopment.pdf
9	1	解析機能	RecipeDevelopment.pdf	2
9	2	データ構造	RecipeDevelopment.pdf	3
9	3	フィルタの拡張	RecipeDevelopment.pdf	5
9	4	補助関数	RecipeDevelopment.pdf	12
10	0	付録：フィルタプラグイン	Filter.pdf
11	0	付録:Malabの基本操作	MATLAB.pdf
12	0	FAQ	FAQ.pdf
13	0	用語集	P3_Words.html
