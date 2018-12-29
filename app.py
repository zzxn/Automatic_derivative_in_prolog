#!usr/bin/env python3
# -*- coding: utf-8 -*-
from tkinter import *
from tkinter.messagebox import *
from pyswip import Prolog
from pyswip.prolog import PrologError
from helper import prefix_to_infix

root = Tk()
root.title('导数计算器')

Label(root, text='函数:').grid(row=0)
Label(root, text='变量:').grid(row=1)
Label(root, text='结果:').grid(row=2)
deriv_func = Entry(root, width=50)
deriv_var = Entry(root, width=50)
deriv_result = Entry(root, width=50)
deriv_func.grid(row=0, column=1, padx=10, pady=5, columnspan=3)
deriv_var.grid(row=1, column=1, padx=10, pady=5, columnspan=3)
deriv_result.grid(row=2, column=1, padx=10, pady=5, columnspan=3)
deriv_result.config(state='readonly')
root.resizable(False, False)


def show_deriv(e=None):
    deriv_result.config(state=NORMAL)
    deriv_result.delete(0, END)
    if (len(deriv_func.get().strip()) == 0):
        deriv_result.insert(0, '必须填写被导的函数')
        return
    elif (deriv_var.get().strip().lower() not in ['x', 'y', 'z']):
        deriv_result.insert(0, '被求导的变量必须是x, y, z之一')
        return

    deriv_result.insert(0, deriv(deriv_func.get().strip().lower(), deriv_var.get().strip().lower()))
    deriv_result.config(state='readonly')


def showhelp():
    showinfo('帮助', '''
    一、在【函数】栏填写要被求导的函数，支持以下符号：
    变量：x、y、z
    常数：由连续的小写字母组成，非变量
    函数：exp(x), ln(x), log2(x), log10(x), log(x, a),
    sin(x), cos(x), tan(x), asin(x), acos(x), atan(x),
    sigmoid(x), relu(x)
    符号：+ - * / ^
    二、在【变量】栏填写对哪个变量求导，变量只能是
    x、y、z之一
    三、填写好后，点击【求导】按钮，
    会在【结果】栏显示出结果，并用化简后的函数表达式替换
    所填写的表达式
    ''')


Prolog.consult('./autodu.pl')


def deriv(y, x):
    try:
        simple_y = next(Prolog.query("sim(%s, Y)" % y))
        result = next(Prolog.query("deriv(%s, %s, Y)" % (y, x)))
    except PrologError:
        return '表达式不合规范，无法计算'
    if result == None or str(result['Y']).find('unknown') >= 0:
        return '表达式不合规范，无法计算'
    deriv_func.delete(0, END)
    deriv_func.insert(0, prefix_to_infix(str(simple_y['Y']).replace(' ', '')))
    return prefix_to_infix(str(result['Y']).replace(' ', ''))


Button(root, text="求导", width=10, command=show_deriv).grid(row=3, column=1, sticky=W, padx=10, pady=5)
Button(root, text="帮助", width=10, command=showhelp).grid(row=3, column=0, sticky=W, padx=10, pady=5)
Button(root, text="退出", width=10, command=root.quit).grid(row=3, column=3, sticky=E, padx=10, pady=5)
root.bind('<Return>', show_deriv)

mainloop()
