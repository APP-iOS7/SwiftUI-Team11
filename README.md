# 🍿 Movie Diary

**영화를 보고 기록하고 평가해봐요!**

## ✅ 목차

- [프로젝트 설명](#프로젝트-후기)
- [개발 기간](#📆-개발-기간)
- [팀원 구성 및 역할](#😎-팀원-구성-및-역할)
- [화면 구성](#📺-화면-구성)
- [주요 기능](#📌-주요-기능)
- [Architecture](#🗂️-architecture)
- [프로젝트 후기](#프로젝트-후기)
- [기술스택과 요구사항](#💻-기술스택과-요구사항)

## 📑 프로젝트 설명

✍🏼 자신이 보았던 영화에 대한 감상 후기를 남길 수 있습니다.

✨ 본인이 느꼈던 감정, 생각 그리고 별점까지 남겨보세요!

❤️ 관심있고 좋아하는 영화는 따로 체크도 할 수 있습니다.

## 📆 개발 기간

25.03.06 ~ 25.03.10

## 😎 팀원 구성 및 역할

|                   이름                    | 역할 |                          작업                          |
| :---------------------------------------: | :--: | :----------------------------------------------------: |
|   [고요한](https://github.com/yohns231)   | 조장 |         Poster Item Detail View 구현, API 구현         |
| [장새벽](https://github.com/saebyeokjang) | 조원 |                    Home View 구현,                     |
|  [심연아](https://github.com/SIMYEONAH)   | 조원 | Poster comment View, Diary List View, Search View 구현 |

## 📺 화면 구성

|         Home View          |      Poster Item Detail View       |      Poster comment View      |      Diary List View       |         Search View          |
| :------------------------: | :--------------------------------: | :---------------------------: | :------------------------: | :--------------------------: |
| <img width="377" alt="Image" src="https://github.com/user-attachments/assets/a4462f56-d1f0-4711-aef3-1b09d4b97111" /> | <img width="379" alt="Image" src="https://github.com/user-attachments/assets/af7e9f3f-a099-4142-927d-9d7a92a52b68" /> | <img width="374" alt="Image" src="https://github.com/user-attachments/assets/70a95709-7848-425a-9a2e-2cc40cfab31f" /> | <img width="376" alt="Image" src="https://github.com/user-attachments/assets/6d346783-fda1-44eb-9606-00fb5baaae33" /> | <img width="374" alt="Image" src="https://github.com/user-attachments/assets/0d3f47e5-e095-4275-b010-36b017fc7937" /> |

**피그마 첨부**
<img width="3216" alt="Image" src="https://github.com/user-attachments/assets/77e6973c-4740-40fe-b4d0-acf60c8bcb30" />


## 📌 주요 기능

## 📌 주요 기능

| View 이름 |  View   | 주요 기능 |
| :-------: | :-----: | :-------: |
|  인트로 시작 화면  | <img src="./introView.gif"> | 스토리보드를 사용한 런치스크린 구현, 홈 화면은 앱 이름과 장르별 그룹화 한 포스터로 구성 |
|  홈 화면 | <img src="./homeViewMove.gif"> | 포스터 아이템을 클릭 시 디테일 화면으로 이동, 장르는 vertical scroll로 배치, 영화 이름 타이틀 밑에 평점 기능 추가 |
|  영화 디테일 화면  |<img src="./posterDetailViewMove.gif"> | 작은 포스터 이미지, 배경에 영화 장면 포스터, 영화 이름, 장르와 같은 기본정보가 표시
평점은 터치나 슬라이드로 매길 수 있으며, 점수는 0.5단위로 매길 수 있으며 0.5부터 시작가능 |
|  코멘트 작성 화면  | <img src="./commentViewMove.gif"> | 코멘트 버튼을 클릭시 코멘트를 작성 가능, 코멘트 수정도 가능|
|  영화록 리스트 화면  | <img src="./movieListLookView.gif"> | 간단한 사용자의 정보를 보여주며,TabBar를 사용해 북마크한 목록과 평점남긴 목록 둘 다 확인 가능, apbar에서 클릭한 아이템에 따라 해당 정보를 리스트로 표현 |
|  겁색 화면  | <img src="./searchViewMove.gif"> | 검색 창이 있으며 검색버튼을 클릭 후 API를 통해 검색, 검색 단어를 자동으로 추천해주는 기능으로 시간이 될 때 추가, Item 클릭시 영화 디테일 화면으로 이동함 |


## 🗂️ Architecture

![Image](https://github.com/user-attachments/assets/ff5c9c6f-de29-46f5-b1d1-67db09e8b690)

## 프로젝트 후기

- 고요한

  - 좋은 점:
    이번 프로젝트의 팀 목적인 “해보지 않았던 기능을 구현하자”에 걸맞게 각자 처음 접하는 분야임에도 밤새 코딩하면서 많은 것을 배울 수 있어서 좋았음.

  - 아쉽거나 어려웠던 점:
    시간 상 많은 커뮤니케이션을 하지 못했고 이로 인해 초반 기획단계에 빼먹은 기능이 많았음.
    초반 프로젝트 생성할 때 프로젝트 구조를 정의하지 못한 점.
    처음 접하는 분야라 허비된 시간이 많았음.

  - 배운 점:
    조금 느리더라도 커뮤니케이션을 활성화 해야 하는 것.
    프로젝트 구조에 대해 미리 팀원과 상의하고 시작해야 하는 것

- 장새벽:
    - 팀원들과의 협업을 통해 커뮤니케이션의 중요성을 느꼈습니다. 그리고 API에 대해서 더 공부하고 싶어졌습니다.
- 심연아: 
    - 작업을 시작하기 전에 폴더명은 어떻게 할지, 어떻게 구상할지 미리 결정하고 작업한 적이 이번 프로젝트가 처음이라 인상 깊습니다. 이번 프로젝트로 통해 스스로 뭐가 부족한지 느꼈고 잘하는 사람과 같이 할 수 있어서 큰 영광이었습니다. 감사합니다.

### 💻 기술스택과 요구사항

- iOS 17.0+
- Swift 6.0+
- Xcode 16.0+
